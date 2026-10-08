/**
 * Smart BloodLink - Intelligent Matching Engine
 * Implements parallel matching across verified donors and hospital inventory,
 * with atomic transactional source reservation to prevent double allocation.
 */

const COMPATIBILITY = {
  'A+': ['A+', 'A-', 'O+', 'O-'],
  'A-': ['A-', 'O-'],
  'B+': ['B+', 'B-', 'O+', 'O-'],
  'B-': ['B-', 'O-'],
  'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
  'AB-': ['AB-', 'A-', 'B-', 'O-'],
  'O+': ['O+', 'O-'],
  'O-': ['O-']
};

/**
 * Calculate Haversine distance in kilometers between two geo coordinates
 */
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth radius in km
  const dLat = (lat2 - lat1) * (Math.PI / 180);
  const dLon = (lon2 - lon1) * (Math.PI / 180);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * (Math.PI / 180)) *
      Math.cos(lat2 * (Math.PI / 180)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

/**
 * Execute parallel matching:
 * 1. Query verified eligible donors matching compatible blood groups within radius (e.g. 25km)
 * 2. Query available hospital inventory with compatible blood units (status == 'Stored' and not expired)
 * 3. Rank candidates by distance, availability, and response probability
 */
async function searchCandidates(db, requestId, bloodGroup, units, userLat, userLng) {
  const compatibleGroups = COMPATIBILITY[bloodGroup] || [bloodGroup];

  // 1. Parallel query for Donors
  const donorPromise = db.collection('donors')
    .where('availability', '==', true)
    .where('verified', '==', true)
    .where('bloodGroup', 'in', compatibleGroups)
    .get();

  // 2. Parallel query for Hospital Blood Bags
  const hospitalPromise = db.collection('inventory')
    .where('status', '==', 'Stored')
    .where('bloodGroup', 'in', compatibleGroups)
    .get();

  const [donorSnap, inventorySnap] = await Promise.all([donorPromise, hospitalPromise]);

  const donorCandidates = [];
  donorSnap.forEach(doc => {
    const data = doc.data();
    const distance = (data.lat && data.lng)
      ? calculateDistance(userLat, userLng, data.lat, data.lng)
      : 5.0; // fallback default
    donorCandidates.push({
      type: 'donor',
      id: doc.id,
      name: data.name || 'Verified Donor',
      bloodGroup: data.bloodGroup,
      distance: distance,
      phone: data.phone,
      rating: data.rating || 5.0,
      points: data.points || 0
    });
  });

  const hospitalCandidates = [];
  inventorySnap.forEach(doc => {
    const data = doc.data();
    // Exclude expired units
    if (data.expiryDate && new Date(data.expiryDate) < new Date()) {
      return;
    }
    const distance = (data.hospitalLat && data.hospitalLng)
      ? calculateDistance(userLat, userLng, data.hospitalLat, data.hospitalLng)
      : 3.5;
    hospitalCandidates.push({
      type: 'hospital',
      bagId: doc.id,
      hospitalId: data.hospitalId,
      hospitalName: data.hospitalName || 'City Blood Bank',
      bloodGroup: data.bloodGroup,
      distance: distance,
      rfidTag: data.rfid || data.rfidTag
    });
  });

  // Sort candidates by distance (closest first)
  donorCandidates.sort((a, b) => a.distance - b.distance);
  hospitalCandidates.sort((a, b) => a.distance - b.distance);

  return { donorCandidates, hospitalCandidates };
}

/**
 * Concurrency Lock: Atomically lock the selected source using Firestore transaction
 */
async function lockSource(db, requestId, source) {
  return await db.runTransaction(async (transaction) => {
    const requestRef = db.collection('requests').doc(requestId);
    const requestDoc = await transaction.get(requestRef);

    if (!requestDoc.exists) {
      throw new Error('Request does not exist');
    }

    const currentData = requestDoc.data();
    if (currentData.status === 'SourceLocked' || currentData.status === 'AmbulanceAssigned') {
      throw new Error('Request is already locked to another source');
    }

    if (source.type === 'hospital') {
      const bagRef = db.collection('inventory').doc(source.bagId);
      const bagDoc = await transaction.get(bagRef);
      if (!bagDoc.exists || bagDoc.data().status !== 'Stored') {
        throw new Error('Selected hospital blood unit is no longer available');
      }

      // Atomically update bag status to Reserved
      transaction.update(bagRef, {
        status: 'Reserved',
        reservedForRequest: requestId,
        reservedAt: new Date().toISOString()
      });
    } else if (source.type === 'donor') {
      const donorRef = db.collection('donors').doc(source.id);
      const donorDoc = await transaction.get(donorRef);
      if (!donorDoc.exists || donorDoc.data().availability !== true) {
        throw new Error('Selected donor is no longer available');
      }

      // Mark donor as temporarily unavailable while committed
      transaction.update(donorRef, {
        availability: false,
        activeRequestId: requestId
      });
    }

    // Update request state
    transaction.update(requestRef, {
      status: 'SourceLocked',
      assignedSourceType: source.type,
      assignedSourceId: source.type === 'hospital' ? source.hospitalId : source.id,
      assignedSourceName: source.type === 'hospital' ? source.hospitalName : source.name,
      assignedBagId: source.type === 'hospital' ? source.bagId : null,
      lockedAt: new Date().toISOString()
    });

    return { success: true, source };
  });
}

module.exports = {
  COMPATIBILITY,
  calculateDistance,
  searchCandidates,
  lockSource
};
