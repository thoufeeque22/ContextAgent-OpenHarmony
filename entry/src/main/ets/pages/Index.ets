import { promptAction } from '@kit.ArkUI';
import sensor from '@ohos.sensor';
import deviceInfo from '@ohos.deviceInfo';
import http from '@ohos.net.http';

@Entry
@Component
struct Index {
  @State recentSummaries: string[] = [
    "System initialized. Ready for context scan."
  ];
  @State isProcessingContext: boolean = false;
  @State documentState: 'idle' | 'scanning' | 'analyzing' = 'idle';
  
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

      // Main Action Buttons
      Column({ space: 16 }) {
        Button() {
          Text(this.documentState === 'idle' ? "Read Private Document" : (this.documentState === 'scanning' ? "Scanning..." : "Analyzing..."))
            .fontSize(24)
            .fontWeight(FontWeight.Bolder)
            .fontColor('#FFFFFF')
        }
        .type(ButtonType.Capsule)
        .width('100%')
        .height(100)
        .backgroundColor(this.documentState !== 'idle' ? '#8C64B4' : '#02BCC1')
        .shadow({ radius: 10, color: '#02BCC1', offsetX: 0, offsetY: 5 })
        .onClick(() => {
          this.triggerDocumentAnalysis();
        })

        Button() {
          Text(this.isProcessingContext ? "Analyzing..." : "What's Around Me?")
            .fontSize(24)
            .fontWeight(FontWeight.Bolder)
            .fontColor('#FFFFFF')
        }
        .type(ButtonType.Capsule)
        .width('100%')
        .height(100)
        .backgroundColor(this.isProcessingContext ? '#8C64B4' : '#E6007E')
        .shadow({ radius: 10, color: '#E6007E', offsetX: 0, offsetY: 5 })
        .onClick(() => {
          this.triggerContextAnalysis();
        })
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 12, bottom: 12 })
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
                  .layoutWeight(1)
              }
              .width('100%')
              .backgroundColor('#2A1A4A')
              .borderRadius(12)
            }
          })
        }
        .width('100%')
        .padding({ left: 24, right: 24, bottom: 24 })
        .layoutWeight(1)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#110527')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#020205')
    .focusable(true)
    .defaultFocus(true)
    .onKeyEvent((event: KeyEvent) => {
      if (event.type === KeyType.Down) {
        // HACKATHON TRICK: Sequential feature toggling.
        // First key press triggers Context, next triggers Document. 
        if (this.lastTriggeredFeature === 2) {
          this.triggerContextAnalysis();
          this.lastTriggeredFeature = 1;
        } else {
          this.triggerDocumentAnalysis();
          this.lastTriggeredFeature = 2;
        }
      }
    })
  }

  private lastTriggeredFeature: number = 2;

  private triggerDocumentAnalysis() {
    if (this.documentState !== 'idle') return;
    this.documentState = 'scanning';

    // Simulate 1.5 seconds of "Scanning" (Local OCR extraction) before Analyzing
    setTimeout(() => {
      this.documentState = 'analyzing';
      
      let simulatedOCRText = "CONFIDENTIAL MEDICAL BILL. Patient: John Doe. Amount Due: $450.00. Due Date: October 15th.";
      let systemPrompt = `You are a helpful AI accessibility assistant running completely offline. The user just scanned a private document with their camera. The extracted text is: "${simulatedOCRText}". Provide a warm, concise, one-sentence auditory summary of this document for a visually impaired user. Do not leak privacy warnings, just summarize the bill.`;

      this.sendToGemma(systemPrompt, 'document');
    }, 1500);
  }

  private triggerContextAnalysis() {
    if (this.isProcessingContext) return;
    this.isProcessingContext = true;

    let environmentDescriptor = "well-lit";
    if (this.ambientLightLevel < 50) {
       environmentDescriptor = "very dark";
    } else if (this.ambientLightLevel < 200) {
       environmentDescriptor = "dimly lit";
    }

    let deviceType = deviceInfo.deviceType ? deviceInfo.deviceType : "smart device";
    
    let systemPrompt = `You are a helpful AI accessibility assistant. The user is visually impaired and holding a ${deviceType}. The device's physical sensors detect that the current environment is ${environmentDescriptor} (${Math.round(this.ambientLightLevel)} lux). Provide a warm, concise, one-sentence auditory description reassuring the user of their environment.`;

    this.sendToGemma(systemPrompt, 'context');
  }

  private sendToGemma(systemPrompt: string, source: 'context' | 'document') {
    let httpRequest = http.createHttp();
    // Use 10.0.2.2 because it is the emulator's alias for the Mac's localhost
    // NOTE: If using the Previewer instead of the Emulator, this should be 127.0.0.1
    let url = "http://10.0.2.2:11434/api/generate";
    
    httpRequest.request(
      url,
      {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify({
          model: "gemma4:latest",
          prompt: systemPrompt,
          stream: false
        }),
        readTimeout: 30000,
        connectTimeout: 30000
      },
      (err, data) => {
        if (source === 'context') {
          this.isProcessingContext = false;
        } else {
          this.documentState = 'idle';
        }
        
        if (!err && data.responseCode === 200) {
          try {
            let res = JSON.parse(data.result as string) as Record<string, Object>;
            let responseText = res['response'] as string;
            
            this.recentSummaries.unshift(responseText);
            if (this.recentSummaries.length > 5) {
              this.recentSummaries.pop();
            }
            
            // Auditory Feedback Trigger
            promptAction.showToast({
              message: 'Speaking: ' + responseText,
              duration: 3000
            });
          } catch (e) {
            this.recentSummaries.unshift("AI Parse Error: Unable to read Gemma 4 output.");
          }
        } else {
          this.recentSummaries.unshift(`Network Error: Ensure Ollama is running on Mac.`);
        }
      }
    );
  }
}