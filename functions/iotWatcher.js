/**
 * Smart BloodLink - IoT Cold Storage Monitoring & Alert Watcher
 * Processes ESP32 temperature telemetry, detects unsafe deviations,
 * distinguishes sensor failures from genuine temperature violations,
 * and triggers immediate push alerts.
 */

const SAFE_TEMP_MIN = 2.0; // Celsius
const SAFE_TEMP_MAX = 6.0; // Celsius
const ALERT_THRESHOLD_SECONDS = 30;

/**
 * Evaluates a new sensor reading against history
 */
async function processSensorReading(db, reading) {
  const { deviceId, storageUnitName, hospitalId, temperature, timestamp } = reading;

  const isSafe = temperature >= SAFE_TEMP_MIN && temperature <= SAFE_TEMP_MAX;
  const isSensorFault = temperature < -30 || temperature > 60; // physical fault range

  // Record reading in sensorReadings collection
  const readingRef = await db.collection('sensorReadings').add({
    deviceId,
    storageUnitName: storageUnitName || 'Blood Storage Unit 1',
    hospitalId,
    temperature,
    timestamp: timestamp || new Date().toISOString(),
    isSafe,
    isSensorFault
  });

  if (!isSafe) {
    // Check recent readings for this device over the past 30 seconds
    const thirtySecondsAgo = new Date(Date.now() - ALERT_THRESHOLD_SECONDS * 1000).toISOString();
    const recentReadingsSnap = await db.collection('sensorReadings')
      .where('deviceId', '==', deviceId)
      .where('timestamp', '>=', thirtySecondsAgo)
      .orderBy('timestamp', 'desc')
      .limit(5)
      .get();

    let persistentViolation = true;
    recentReadingsSnap.forEach(doc => {
      const data = doc.data();
      if (data.isSafe) persistentViolation = false;
    });

    if (persistentViolation || isSensorFault) {
      const alertTitle = isSensorFault
        ? `⚠️ IoT Sensor Hardware Fault: ${deviceId}`
        : `🚨 Critical Cold-Chain Alert: ${storageUnitName || deviceId}`;

      const alertBody = isSensorFault
        ? `Unrealistic sensor value detected (${temperature}°C). Check sensor probe connection.`
        : `Storage temperature (${temperature}°C) is outside safe range (2°C - 6°C) for over 30s!`;

      // Log alert
      await db.collection('auditLogs').add({
        actorId: deviceId,
        actorName: 'ESP32 Cold Storage Telemetry',
        actorRole: 'IoT Gateway',
        action: 'STORAGE_TEMPERATURE_BREACH',
        entityType: 'ColdStorageUnit',
        entityId: deviceId,
        details: `${alertTitle}: ${alertBody}`,
        severity: 'Critical',
        timestamp: new Date().toISOString()
      });

      // Dispatch alert notification to hospital staff and admin
      await db.collection('notifications').add({
        title: alertTitle,
        body: alertBody,
        type: 'COLD_CHAIN_ALERT',
        hospitalId,
        deviceId,
        temperature,
        isRead: false,
        timestamp: new Date().toISOString()
      });

      return { alertTriggered: true, alertTitle, alertBody };
    }
  }

  return { alertTriggered: false };
}

module.exports = {
  SAFE_TEMP_MIN,
  SAFE_TEMP_MAX,
  ALERT_THRESHOLD_SECONDS,
  processSensorReading
};
