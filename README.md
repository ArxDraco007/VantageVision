# Vantage: AI-Powered Wearable Vision

Real-time spatial awareness for the visually impaired.

Vantage is an AI-driven "Co-Pilot" that merges global navigation with local safety, enabling the visually impaired with spatial and situational awareness by integrating GPS routing with Computer Vision to allow a visually impaired person to travel from their doorstep to any destination independently.
Current tools force the user to choose between Google Maps, ignoring obstacles, or a White Cane, which has no map. The current market solves this with expensive hardware ($3,000+). This creates a "safety tax" that most people in developing regions cannot afford. By combining an LLM-based voice assistant for routing with edge-based hazard detection, we provide the first "End-to-End" autonomy solution, tackling both the physical danger of navigation and the economic barrier.

---

## Technical Specifications

| Component        | Choice                         | Rationale                                                  |
|-----------------|--------------------------------|------------------------------------------------------------|
| Processor        | Raspberry Pi 5 (8GB)           | High-speed throughput for real-time YOLO processing         |
| AI Accelerator   | Raspberry Pi AI HAT+           | 13 TOPS performance via the Hailo-8 chip                    |
| Vision System    | USB Mini-Module                | Improved durability over ribbon cable-based cameras         |
| Framework        | Flutter                        | Cross-platform support for Android and iOS                  |
| Model            | YOLO26n                         | Optimized for edge inference   |

---

## Engineering and Design

### Thermal Management ("Anti-Sandwich" Design)

A key engineering challenge identified during development was thermal buildup caused by stacking the AI HAT+ directly on top of the Raspberry Pi, creating a "heat sandwich."

To resolve this:
- The enclosure was redesigned to position the active cooling system above the compute stack
- Dedicated ventilation intake paths were introduced
- Heat dissipation was optimized for sustained inference workloads

This design ensures both the CPU and AI accelerator maintain safe operating temperatures under continuous load.

### CAD Enclosure

The enclosure was custom-designed using Autodesk Fusion 360 with the following features:

- **Unibody Harness**: Integrated 1-inch (25 mm) strap slots for chest or waist mounting
- **Precision Port Mapping**: Accurate cutouts for USB, power, and I/O access
- **Translucent Housing**: Allows visual inspection of internal status LEDs without disassembly

---

## AI Performance Results

The object detection model was trained on a custom-curated dataset including stairs, curbs, doors, and furniture. Training was conducted on dual NVIDIA T4 GPUs using Kaggle over 100 epochs.

### Model Metrics

- Precision (P): 0.852  
- Recall (R): 0.742  
- mAP@50: 0.831  
- mAP@50-95: 0.589  

These results indicate strong detection performance suitable for real-world deployment scenarios.

---

## Development Journey

### Phase 1: Foundation and Application Development

- Initially developed in Kotlin, later transitioned to Flutter for cross-platform support
- Built initial user interface
- Integrated a temporary TensorFlow Lite model for early-stage validation
![image](https://stasis.hackclub-assets.com/images/1772770740793-fsjedo.png)

### Phase 2: Data Science and Model Training

- Aggregated datasets from Roboflow
- Migrated from Google Colab to Kaggle for improved GPU performance
- Achieved 83% mAP@50, validating readiness for real-world testing
![image](https://stasis.hackclub-assets.com/images/1772951521635-yt05k3.png)
![image](https://stasis.hackclub-assets.com/images/1772951521236-j1kko3.png)

### Phase 3: CAD and Enclosure Design

- Learned Autodesk Fusion 360 from scratch
- Addressed component fitting challenges by breaking external references
- Applied a 1.1x clearance factor to ensure proper internal fitment
![image](https://stasis.hackclub-assets.com/images/1773905220049-x1b28d.png)

### Phase 4: Hardware Integration (Current)

- Finalized the "Brain Box" assembly
- Transitioned from Pi Camera ribbon cables to a USB camera module to improve reliability during motion
- Resolved thermal constraints by repositioning the cooling system
![image](https://stasis.hackclub-assets.com/images/1774194197082-py714i.png)
![image](https://stasis.hackclub-assets.com/images/1774194196919-x11cjl.png)

---

## Conclusion

Vantage represents a convergence of edge AI and robust hardware with human-centered design. By combining efficient hardware with optimized machine learning models, it aims to deliver real-time environmental awareness in a compact, wearable form factor.

This project continues to evolve toward robust real-world deployment and accessibility impact.
