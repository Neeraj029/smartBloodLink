const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

const { searchCandidates, lockSource } = require('./matchingEngine');
const { processSensorReading } = require('./iotWatcher');

/**
 * Triggered when a patient creates an emergency blood request
 */
exports.onBloodRequestCreated = functions.firestore
  .document('requests/{requestId}')
  .onCreate(async (snap, context) => {
    const requestData = snap.data();
    const requestId = context.params.requestId;

    try {
      const userLat = requestData.location?.lat || 18.5204;
      const userLng = requestData.location?.lng || 73.8567;
      const bloodGroup = requestData.bloodGroup;
      const units = requestData.units || 1;

      // 1. Parallel search for eligible donors and hospital inventory
      const { donorCandidates, hospitalCandidates } = await searchCandidates(
        db,
        requestId,
        bloodGroup,
        units,
        userLat,
        userLng
      );

      // If a nearby hospital has inventory in stock, prioritize hospital stock for speed
      let chosenSource = null;
      if (hospitalCandidates.length > 0 && hospitalCandidates[0].distance <= 15.0) {
        chosenSource = hospitalCandidates[0];
      } else if (donorCandidates.length > 0) {
        chosenSource = donorCandidates[0];
      } else if (hospitalCandidates.length > 0) {
        chosenSource = hospitalCandidates[0];
      }

      if (chosenSource) {
        // Automatically attempt source reservation
        await lockSource(db, requestId, chosenSource);

        // Notify patient
        await db.collection('notifications').add({
          userId: requestData.patientId,
          title: 'Blood Source Matched! 🩸',
          body: `A match was found at ${chosenSource.type === 'hospital' ? chosenSource.hospitalName : chosenSource.name}. Ambulance dispatch initiated.`,
          type: 'MATCH_CONFIRMED',
          requestId,
          timestamp: new Date().toISOString(),
          isRead: false
        });
      } else {
        // Update request status to BroadcastSearching
        await snap.ref.update({
          status: 'Searching',
          matchingNote: 'Broadcasting emergency request to all nearby centers.'
        });
      }
    } catch (err) {
      console.error('Error in onBloodRequestCreated:', err);
    }
  });

/**
 * Triggered when an ambulance updates its GPS coordinates
 */
exports.onAmbulanceGpsUpdate = functions.firestore
  .document('ambulanceTrips/{tripId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Check if location changed
    if (afterData.currentLocation && (!beforeData.currentLocation ||
        beforeData.currentLocation.lat !== afterData.currentLocation.lat ||
        beforeData.currentLocation.lng !== afterData.currentLocation.lng)) {

      // Update ETA (average speed 40km/h in emergency)
      const destLat = afterData.destinationLocation?.lat;
      const destLng = afterData.destinationLocation?.lng;
      if (destLat && destLng) {
        const { calculateDistance } = require('./matchingEngine');
        const distanceRemaining = calculateDistance(
          afterData.currentLocation.lat,
          afterData.currentLocation.lng,
          destLat,
          destLng
        );
        const etaMinutes = Math.max(1, Math.round((distanceRemaining / 40.0) * 60));

        await change.after.ref.update({
          distanceRemainingKm: parseFloat(distanceRemaining.toFixed(2)),
          etaMinutes: etaMinutes,
          lastGpsUpdate: new Date().toISOString()
        });
      }
    }
  });

/**
 * Process IoT temperature readings from ESP32 gateway
 */
exports.recordSensorTelemetry = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).send('Method Not Allowed');
  }

  const { deviceId, storageUnitName, hospitalId, temperature, timestamp } = req.body;
  if (!deviceId || temperature === undefined) {
    return res.status(400).send('Missing deviceId or temperature');
  }

  try {
    const result = await processSensorReading(db, {
      deviceId,
      storageUnitName,
      hospitalId: hospitalId || 'HOSP-001',
      temperature: parseFloat(temperature),
      timestamp: timestamp || new Date().toISOString()
    });

    return res.status(200).json({ success: true, ...result });
  } catch (err) {
    console.error('Error recording telemetry:', err);
    return res.status(500).json({ error: err.message });
  }
});

/**
 * Award points & badges upon verified blood donation
 */
exports.onDonationCompleted = functions.firestore
  .document('donations/{donationId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const donorId = data.donorId;
    const isEmergency = data.isEmergency || false;

    // Normal donation: 100 points. Emergency request: 150 points.
    const pointsAwarded = isEmergency ? 150 : 100;

    const donorRef = db.collection('donors').doc(donorId);
    await db.runTransaction(async (t) => {
      const donorDoc = await t.get(donorRef);
      if (!donorDoc.exists) return;

      const currentPoints = donorDoc.data().points || 0;
      const totalDonations = (donorDoc.data().totalDonations || 0) + 1;
      const livesSaved = (donorDoc.data().livesSaved || 0) + 3;

      const newPoints = currentPoints + pointsAwarded;
      const badges = donorDoc.data().badges || [];

      // Check badge thresholds
      if (totalDonations >= 1 && !badges.includes('First Drop 🩸')) {
        badges.push('First Drop 🩸');
      }
      if (totalDonations >= 5 && !badges.includes('Life Saver ⭐')) {
        badges.push('Life Saver ⭐');
      }
      if (isEmergency && !badges.includes('Emergency Hero ⚡')) {
        badges.push('Emergency Hero ⚡');
      }

      t.update(donorRef, {
        points: newPoints,
        totalDonations: totalDonations,
        livesSaved: livesSaved,
        badges: badges,
        lastDonationDate: new Date().toISOString()
      });
    });
  });

/**
 * Admin action: verify or suspend user account
 */
exports.adminSetAccountStatus = functions.https.onCall(async (data, context) => {
  const { userId, status, reason } = data; // status: 'approved', 'suspended', 'rejected'
  
  await db.collection('users').doc(userId).update({
    status: status,
    statusReason: reason || '',
    updatedAt: new Date().toISOString()
  });

  // Log to auditLogs
  await db.collection('auditLogs').add({
    actorId: context.auth ? context.auth.uid : 'admin-action',
    actorName: 'Administrator',
    actorRole: 'admin',
    action: `ACCOUNT_${status.toUpperCase()}`,
    entityType: 'User',
    entityId: userId,
    details: `User status changed to ${status}. Reason: ${reason || 'N/A'}`,
    severity: status === 'suspended' ? 'Warning' : 'Info',
    timestamp: new Date().toISOString()
  });

  return { success: true };
});
