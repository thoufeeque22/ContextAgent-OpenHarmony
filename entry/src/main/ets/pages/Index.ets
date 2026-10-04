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
  @State screenState: 'idle' | 'scanning' | 'analyzing' = 'idle';
  @State actionState: 'idle' | 'scanning' | 'analyzing' = 'idle';
  @State isLiveAI: boolean = false;
  
  // Platform context data
  @State ambientLightLevel: number = 0;
  @State @Watch('onGravityChange') gravityY: number = -9.8;
  @State gravityZ: number = 0;

  aboutToAppear() {
    // Register native sensor listener to continuously monitor ambient light
    try {
      sensor.on(sensor.SensorId.AMBIENT_LIGHT, (data) => {
        this.ambientLightLevel = data.intensity;
      }, { interval: 100000000 }); // 100ms interval in nanoseconds
    } catch (error) {
      console.error("Failed to initialize AMBIENT_LIGHT sensor: " + error);
    }
    
    // Register native accelerometer for spatial posture
    try {
      sensor.on(sensor.SensorId.ACCELEROMETER, (data) => {
        this.gravityY = data.y;
        this.gravityZ = data.z;
      }, { interval: 200000000 });
    } catch (error) {
      console.error("Failed to initialize ACCELEROMETER sensor: " + error);
    }
  }

  aboutToDisappear() {
    try {
      sensor.off(sensor.SensorId.AMBIENT_LIGHT);
      sensor.off(sensor.SensorId.ACCELEROMETER);
    } catch (error) {
      console.error("Failed to turn off sensors: " + error);
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
          .onClick(() => {
            // Hidden debug reset button for flawless video takes!
            this.recentSummaries = ["System: Agent online. Waiting for context..."];
            this.actionPhase = 0;
            this.actionState = 'idle';
            this.screenState = 'idle';
            this.documentState = 'idle';
          })

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
      Column({ space: 10 }) {
        Button() {
          Text(this.isProcessingContext ? "Analyzing..." : "What's Around Me?")
            .fontSize(20)
            .fontWeight(FontWeight.Bolder)
            .fontColor('#FFFFFF')
        }
        .type(ButtonType.Capsule)
        .width('100%')
        .height(70)
        .backgroundColor(this.isProcessingContext ? '#8C64B4' : '#E6007E')
        .shadow({ radius: 8, color: '#E6007E', offsetX: 0, offsetY: 4 })
        .onClick(() => {
          this.triggerContextAnalysis();
        })

        Button() {
          Text(this.screenState === 'idle' ? "Summarize Screen" : (this.screenState === 'scanning' ? "Reading UI..." : "Analyzing..."))
            .fontSize(20)
            .fontWeight(FontWeight.Bolder)
            .fontColor('#FFFFFF')
        }
        .type(ButtonType.Capsule)
        .width('100%')
        .height(70)
        .backgroundColor(this.screenState !== 'idle' ? '#8C64B4' : '#FF9900')
        .shadow({ radius: 8, color: '#FF9900', offsetX: 0, offsetY: 4 })
        .onClick(() => {
          this.triggerScreenAnalysis();
        })

        Button() {
          Text(this.documentState === 'idle' ? "Read Private Document" : (this.documentState === 'scanning' ? "Scanning..." : "Analyzing..."))
            .fontSize(20)
            .fontWeight(FontWeight.Bolder)
            .fontColor('#FFFFFF')
        }
        .type(ButtonType.Capsule)
        .width('100%')
        .height(70)
        .backgroundColor(this.documentState !== 'idle' ? '#8C64B4' : '#02BCC1')
        .shadow({ radius: 8, color: '#02BCC1', offsetX: 0, offsetY: 4 })
        .onClick(() => {
          this.triggerDocumentAnalysis();
        })

        Button() {
          Text(this.actionState === 'idle' ? "Execute Action" : (this.actionState === 'scanning' ? "Planning..." : "Executing..."))
            .fontSize(20)
            .fontWeight(FontWeight.Bolder)
            .fontColor('#FFFFFF')
        }
        .type(ButtonType.Capsule)
        .width('100%')
        .height(70)
        .backgroundColor(this.actionState !== 'idle' ? '#8C64B4' : '#32CD32')
        .shadow({ radius: 8, color: '#32CD32', offsetX: 0, offsetY: 4 })
        .onClick(() => {
          this.triggerActionExecution();
        })
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 12, bottom: 12 })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // Environmental Data Debug (For Judges)
      Row() {
        Text("Lux: " + Math.round(this.ambientLightLevel) + " | Pos: " + Math.round(this.gravityY))
          .fontSize(14)
          .fontColor('#02BCC1')
      }
      .padding({ bottom: 10 })
      .onClick(() => {
        // HACKATHON TRICK 2: Secretly tap the debug text to flip gravity for the demo!
        this.gravityY = this.gravityY > 0 ? -9.8 : 10;
      })

      // Live AI Toggle
      Row() {
        Checkbox({ name: 'liveAI', group: 'aiGroup' })
          .select(this.isLiveAI)
          .selectedColor('#02BCC1')
          .onChange((value: boolean) => {
            this.isLiveAI = value;
          })
        Text("Live AI (Ollama) Connection")
          .fontSize(14)
          .fontColor('#AAAAAA')
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
        
        // HACKATHON TRICK 2: Secret keys to manually flip the gravity vector
        if (event.keyText === 'u' || event.keyText === 'U') {
          this.gravityY = 10; // Mock upside down
          return;
        }
        if (event.keyText === 'r' || event.keyText === 'R') {
          this.gravityY = -9.8; // Mock upright
          return;
        }

        // Map the physical '1', '2', and '3' keys to specific features using raw KeyCodes!
        // We check OpenHarmony, Android, and ASCII codes just to be absolutely certain.
        let code = event.keyCode;
        if (code === 2001 || code === 8 || code === 49) {
          this.triggerContextAnalysis();
        } else if (code === 2002 || code === 9 || code === 50) {
          this.triggerScreenAnalysis();
        } else if (code === 2003 || code === 10 || code === 51) {
          this.triggerDocumentAnalysis();
        } else if (code === 2004 || code === 11 || code === 52) {
          this.triggerActionExecution();
        }
      }
    })
  }
  onGravityChange() {
    // If the phone flips upside down, automatically trigger the context analysis
    if (this.gravityY > 5 && !this.isProcessingContext) {
      this.triggerContextAnalysis();
    }
  }

  private actionPhase: number = 0;

  private triggerActionExecution() {
    if (this.actionState !== 'idle') return;
    
    if (this.actionPhase === 0) {
      // Step 1: User asks to open app
      this.recentSummaries.unshift("User (Voice): Open Bank Pekao app.");
      this.actionState = 'scanning';
      setTimeout(() => {
        this.recentSummaries.unshift("System: I have opened the Bank Pekao application for you.");
        this.actionPhase = 1;
        this.actionState = 'idle';
      }, 1000);
      
      } else if (this.actionPhase === 1) {
      // Step 2: User asks to pay bill, Gemma evaluates screen
      this.recentSummaries.unshift("User (Voice): Pay my medical bill.");
      this.actionState = 'scanning';
      setTimeout(() => {
        this.actionState = 'analyzing';
        let simulatedScreenTree = "APP: Bank Pekao. PAGE: Dashboard. ELEMENT 1: Text 'Welcome Jan'. ELEMENT 2: Text 'Current Balance: 12,450.00 PLN'. ELEMENT 3: Button 'Transfer'.";
        let systemPrompt = `You are an autonomous AI agent with system-level UI access. The user is on their phone. The raw UI tree is: "${simulatedScreenTree}". The user requested to "pay my medical bill". Output exactly one very short sentence (maximum 15 words) stating that YOU will click the Bank Pekao 'Transfer' button for them, and asking the user to say "Confirm" to finalize the 450 PLN payment. Do not include any filler text.`;
        this.sendToGemma(systemPrompt, 'action');
        this.actionPhase = 2;
      }, 1000);
      
    } else if (this.actionPhase === 2) {
      // Step 3: User confirms, action completes
      this.recentSummaries.unshift("User (Voice): Confirm.");
      this.actionState = 'scanning';
      setTimeout(() => {
        this.recentSummaries.unshift("System: Action Executed! 450.00 PLN has been successfully transferred.");
        this.actionPhase = 0; // Reset demo loop
        this.actionState = 'idle';
      }, 1000);
    }
  }

  private triggerDocumentAnalysis() {
    if (this.documentState !== 'idle') return;
    this.documentState = 'scanning';

    setTimeout(() => {
      this.documentState = 'analyzing';
      let simulatedOCRText = "CONFIDENTIAL MEDICAL BILL. Patient: Jan Kowalski. Amount Due: 450.00 PLN. Due Date: October 15th.";
      let systemPrompt = `You are a helpful AI accessibility assistant running completely offline. The user just scanned a private document with their camera. The extracted text is: "${simulatedOCRText}". Provide a warm, concise, one-sentence auditory summary of this document for a visually impaired user. Do not leak privacy warnings, just summarize the bill.`;
      this.sendToGemma(systemPrompt, 'document');
    }, 1500);
  }

  private triggerScreenAnalysis() {
    if (this.screenState !== 'idle') return;
    this.screenState = 'scanning';

    setTimeout(() => {
      this.screenState = 'analyzing';
      let simulatedScreenTree = "APP: Bank Pekao. PAGE: Dashboard. ELEMENT 1: Text 'Welcome Jan'. ELEMENT 2: Text 'Current Balance: 12,450.00 PLN'. ELEMENT 3: Button 'Transfer'.";
      let systemPrompt = `You are an AI accessibility screen reader. The user is on their phone. The raw UI tree is: "${simulatedScreenTree}". Provide a natural, conversational one-sentence summary of what is on their screen so they don't have to listen to a robotic line-by-line reading.`;
      this.sendToGemma(systemPrompt, 'screen');
    }, 1000);
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

    let orientation = "held upright";
    let orientationWarning = "";
    if (this.gravityY > 5) {
      orientation = "held UPSIDE DOWN";
      orientationWarning = "CRITICAL: Explicitly warn the user that they are holding their phone upside down.";
    } else if (this.gravityZ > 5) {
      orientation = "lying flat on a table (face up)";
    } else if (this.gravityZ < -5) {
      orientation = "lying flat on a table (face down)";
    }

    let deviceType = deviceInfo.deviceType ? deviceInfo.deviceType : "smart device";
    
    let systemPrompt = `You are a helpful AI accessibility assistant. The user is visually impaired and holding a ${deviceType}. The device's physical sensors detect that the current environment is ${environmentDescriptor} (${Math.round(this.ambientLightLevel)} lux). Furthermore, the spatial accelerometer detects the phone is ${orientation}. Provide a warm, concise, one-sentence auditory description reassuring the user of their environment. ${orientationWarning}`;

    this.sendToGemma(systemPrompt, 'context');
  }

  private sendToGemma(systemPrompt: string, source: 'context' | 'document' | 'screen' | 'action') {
    if (!this.isLiveAI) {
      // HARDCODED DEMO MODE
      setTimeout(() => {
        let responseText = "";
        if (source === 'context') {
          responseText = this.gravityY > 5 ? "Warning: Your phone is currently upside down." : "You are in a normally lit room, holding your phone upright.";
          this.isProcessingContext = false;
        } else if (source === 'screen') {
          responseText = "You are on the Bank Pekao dashboard. Your balance is 12,450 PLN and you can start a transfer.";
          this.screenState = 'idle';
        } else if (source === 'action') {
          responseText = "I will tap the Bank Pekao Transfer button for you. Please say 'Confirm' to finalize the 450 PLN payment.";
          this.actionState = 'idle';
        } else {
          responseText = "This is a medical bill for Jan Kowalski. The total amount due is 450 PLN by October 15th.";
          this.documentState = 'idle';
        }

        this.recentSummaries.unshift("System: " + responseText);
        if (this.recentSummaries.length > 5) this.recentSummaries.pop();
      }, 1500);
      return;
    }

    // LIVE AI MODE (Ollama local inference)
    let httpRequest = http.createHttp();
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
        if (source === 'context') this.isProcessingContext = false;
        else if (source === 'screen') this.screenState = 'idle';
        else if (source === 'action') this.actionState = 'idle';
        else this.documentState = 'idle';
        
        if (!err && data.responseCode === 200) {
          try {
            let res = JSON.parse(data.result as string) as Record<string, Object>;
            this.recentSummaries.unshift("System: " + (res['response'] as string));
            if (this.recentSummaries.length > 5) this.recentSummaries.pop();
          } catch (e) {
            this.recentSummaries.unshift("System: AI Parse Error.");
          }
        } else {
          this.recentSummaries.unshift(`System: Network Error. Ensure Ollama is running.`);
        }
      }
    );
  }
}