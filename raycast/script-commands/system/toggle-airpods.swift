#!/usr/bin/swift

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Toggle AirPods
// @raycast.mode silent

// Optional parameters:
// @raycast.packageName Audio
// @raycast.icon images/airpods.png

import IOBluetooth

func toggleAirPods() {
    guard let bluetoothDevice = IOBluetoothDevice(addressString: "24-D0-DF-84-76-F8") else {
        print("Device not found")
        exit(-2)
    }

    if !bluetoothDevice.isPaired() {
        print("Device not paired")
        exit(-4)
    }

    if bluetoothDevice.isConnected() {
        print("AirPods Disconnected")
        bluetoothDevice.closeConnection()
    } else {
        print("AirPods Connected")
        bluetoothDevice.openConnection()
    }
}

toggleAirPods()