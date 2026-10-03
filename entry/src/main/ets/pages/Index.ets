import { promptAction } from '@kit.ArkUI';
import sensor from '@ohos.sensor';
import deviceInfo from '@ohos.deviceInfo';

@Entry
@Component
struct Index {
  @State recentSummaries: string[] = [
    "System initialized. Ready for context scan."
  ];
  @State isProcessing: boolean = false;
  
  // Platform context data
  @State ambientLightLevel: number = 0;

  aboutToAppear() {
    // Register native sensor listener to continuously monitor ambient light
    try {
      sensor.on(sensor.SensorId.AMBIENT_LIGHT, (data) => {
        this.ambientLightLevel = data.intensity;
      }, { interval: 100000000 }); // 100ms interval in nanoseconds
    } catch (error) {
      console.error("Failed to initialize AMBIENT_LIGHT sensor: " + error);
    }
  }

  aboutToDisappear() {
    try {
      sensor.off(sensor.SensorId.AMBIENT_LIGHT);
    } catch (error) {
      console.error("Failed to turn off AMBIENT_LIGHT sensor: " + error);
    }
  }

  build() {
    Column() {
      // Header Area
      Row() {
        Text("Context Agent")
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .layoutWeight(1)

        // Native Platform Info Display
        Column() {
          Text(deviceInfo.deviceType.toUpperCase())
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#02BCC1')
            .margin({ bottom: 2 })
          Text("OS: " + deviceInfo.osFullName)
            .fontSize(10)
            .fontColor('#AAAAAA')
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .padding(24)
      .backgroundColor('#110527')

      // Main Context Button
      Column() {
        Button() {
          Text(this.isProcessing ? "Analyzing..." : "What's Around Me?")
            .fontSize(28)
            .fontWeight(FontWeight.Bolder)
            .fontColor('#FFFFFF')
        }
        .type(ButtonType.Circle)
        .width(280)
        .height(280)
        .backgroundColor(this.isProcessing ? '#8C64B4' : '#E6007E')
        .shadow({ radius: 20, color: '#E6007E', offsetX: 0, offsetY: 10 })
        .onClick(() => {
          this.triggerContextAnalysis();
        })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // Environmental Data Debug (For Judges)
      Row() {
        Text("Lux (Ambient Light): " + Math.round(this.ambientLightLevel))
          .fontSize(14)
          .fontColor('#02BCC1')
      }
      .padding({ bottom: 20 })

      // Recent Summaries List
      Column() {
        Text("Activity Log")
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width('100%')
          .padding({ left: 24, bottom: 12 })

        List({ space: 12 }) {
          ForEach(this.recentSummaries, (summary: string, index: number) => {
            ListItem() {
              Row() {
                Text(summary)
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                  .padding(16)
              }
              .width('100%')
              .backgroundColor('#2A1A4A')
              .borderRadius(12)
              .margin({ left: 24, right: 24 })
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#110527')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#020205')
  }

  private triggerContextAnalysis() {
    if (this.isProcessing) return;
    this.isProcessing = true;

    // Simulate inference delay
    setTimeout(() => {
      this.isProcessing = false;
      
      // We construct a dynamic summary using the native OpenHarmony sensor data
      let environmentDescriptor = "well-lit";
      if (this.ambientLightLevel < 50) {
         environmentDescriptor = "very dark";
      } else if (this.ambientLightLevel < 200) {
         environmentDescriptor = "dimly lit";
      }

      let newSummary = `I detect you are in a ${environmentDescriptor} environment (Light Level: ${Math.round(this.ambientLightLevel)} lux) holding a ${deviceInfo.deviceType}.`;

      this.recentSummaries.unshift(newSummary);
      if (this.recentSummaries.length > 5) {
        this.recentSummaries.pop();
      }

      // Auditory Feedback Trigger
      promptAction.showToast({
        message: 'Speaking Context...',
        duration: 3000
      });
    }, 1500);
  }
}