#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

// กำหนดขาที่เชื่อมต่อกับรีเลย์ทั้ง 4 ช่อง
#define RELAY_PIN_1 23  // ช่อง 1
#define RELAY_PIN_2 22  // ช่อง 2
#define RELAY_PIN_3 21  // ช่อง 3
#define RELAY_PIN_4 19  // ช่อง 4

// UUID สำหรับ BLE Service และ Characteristic
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

// สถานะรีเลย์ทั้ง 4 ช่อง (เริ่มต้นเป็น OFF)
bool relayState1 = false;
bool relayState2 = false;
bool relayState3 = false;
bool relayState4 = false;

// คลาสสำหรับรับคำสั่งจาก BLE
class MyCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string value = std::string(pCharacteristic->getValue().c_str());  // รับค่าจาก characteristic

      if (value.length() > 0) {
        String command = String(value.c_str());  // แปลงค่าเป็น String

        // ตรวจสอบคำสั่งและควบคุมรีเลย์
        if (command == "ON1") {
          digitalWrite(RELAY_PIN_1, LOW);  // เปิดรีเลย์ช่อง 1
          relayState1 = true;
          Serial.println("Relay 1 ON");
        } else if (command == "OFF1") {
          digitalWrite(RELAY_PIN_1, HIGH);  // ปิดรีเลย์ช่อง 1
          relayState1 = false;
          Serial.println("Relay 1 OFF");
        } else if (command == "ON2") {
          digitalWrite(RELAY_PIN_2, LOW);  // เปิดรีเลย์ช่อง 2
          relayState2 = true;
          Serial.println("Relay 2 ON");
        } else if (command == "OFF2") {
          digitalWrite(RELAY_PIN_2, HIGH);  // ปิดรีเลย์ช่อง 2
          relayState2 = false;
          Serial.println("Relay 2 OFF");
        } else if (command == "ON3") {
          digitalWrite(RELAY_PIN_3, LOW);  // เปิดรีเลย์ช่อง 3
          relayState3 = true;
          Serial.println("Relay 3 ON");
        } else if (command == "OFF3") {
          digitalWrite(RELAY_PIN_3, HIGH);  // ปิดรีเลย์ช่อง 3
          relayState3 = false;
          Serial.println("Relay 3 OFF");
        } else if (command == "ON4") {
          digitalWrite(RELAY_PIN_4, LOW);  // เปิดรีเลย์ช่อง 4
          relayState4 = true;
          Serial.println("Relay 4 ON");
        } else if (command == "OFF4") {
          digitalWrite(RELAY_PIN_4, HIGH);  // ปิดรีเลย์ช่อง 4
          relayState4 = false;
          Serial.println("Relay 4 OFF");
        } else {
          Serial.println("Unknown command: " + command);
        }
      }
    }
};

// คลาสสำหรับตรวจจับการเชื่อมต่อและตัดการเชื่อมต่อ
class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      Serial.println("Device connected");
    }

    void onDisconnect(BLEServer* pServer) {
      Serial.println("Device disconnected. Restarting advertising...");
      pServer->startAdvertising();  // เริ่มโฆษณาใหม่เมื่ออุปกรณ์ตัดการเชื่อมต่อ
    }
};

void setup() {
  Serial.begin(115200);

  // ตั้งค่าโหมดพินสำหรับรีเลย์ทั้ง 4 ช่อง
  pinMode(RELAY_PIN_1, OUTPUT);
  pinMode(RELAY_PIN_2, OUTPUT);
  pinMode(RELAY_PIN_3, OUTPUT);
  pinMode(RELAY_PIN_4, OUTPUT);

  // เริ่มต้นปิดรีเลย์ทั้งหมด
  digitalWrite(RELAY_PIN_1, HIGH);
  digitalWrite(RELAY_PIN_2, HIGH);
  digitalWrite(RELAY_PIN_3, HIGH);
  digitalWrite(RELAY_PIN_4, HIGH);

  // เริ่มต้น BLE
  BLEDevice::init("ESP32_RELAY_CONTROL");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());  // ตั้งค่า callback สำหรับการเชื่อมต่อ

  BLEService *pService = pServer->createService(SERVICE_UUID);
  BLECharacteristic *pCharacteristic = pService->createCharacteristic(
                                         CHARACTERISTIC_UUID,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_WRITE
                                       );

  pCharacteristic->setCallbacks(new MyCallbacks());  // ตั้งค่า callback สำหรับรับคำสั่ง
  pCharacteristic->setValue("Relay Control");  // ตั้งค่าเริ่มต้น
  pService->start();

  // เริ่มโฆษณา BLE
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  Serial.println("BLE Server Started. Waiting for commands...");
}

void loop() {
  // ไม่ต้องทำอะไรใน loop
}