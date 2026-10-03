import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State recentSummaries: string[] = [
    "Detected a coffee mug on the table in front of you.",
    "The text on the screen is an article about OpenHarmony.",
    "Notification: 'Meeting in 5 minutes'."
  ];
  @State isLiveAIEnabled: boolean = true;
  @State isProcessing: boolean = false;

  private mockSummaries: string[] = [
    "A person is standing approximately 2 meters away.",
    "A stop sign is visible straight ahead.",
    "You are holding a bottle of water."
  ];

  build() {
    Column() {
      // Header Area
      Row() {
        Text("Context Agent")
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .layoutWeight(1)

        // Wizard of Oz Toggle
        Column() {
          Text("Live AI")
            .fontSize(12)
            .fontColor('#AAAAAA')
            .margin({ bottom: 4 })
          Toggle({ type: ToggleType.Switch, isOn: $$this.isLiveAIEnabled })
            .selectedColor('#02BCC1')
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding(24)
      .backgroundColor('#110527')

      // Main Context Button
      Column() {
        Button() {
          Text(this.isProcessing ? "Analyzing Context..." : "What's Around Me?")
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

      // Recent Summaries List
      Column() {
        Text("Recent Activity")
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
                  .fontSize(18)
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

    // Simulate AI inference delay
    setTimeout(() => {
      this.isProcessing = false;
      
      let newSummary = "";
      if (this.isLiveAIEnabled) {
        // TODO: Replace with actual local gemma4 inference call via Native C++ / RPC
        newSummary = "[Live AI] Analyzed camera and screen context successfully.";
      } else {
        // "Wizard of Oz" Mode
        const randomIndex = Math.floor(Math.random() * this.mockSummaries.length);
        newSummary = this.mockSummaries[randomIndex];
      }

      this.recentSummaries.unshift(newSummary);
      if (this.recentSummaries.length > 5) {
        this.recentSummaries.pop();
      }

      // Auditory Feedback (Mocked for now)
      promptAction.showToast({
        message: 'Speaking: ' + newSummary,
        duration: 3000
      });
    }, 1500);
  }
}