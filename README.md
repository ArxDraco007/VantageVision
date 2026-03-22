# Vantage: AI-Powered Wearable Vision

Real-time spatial awareness for the visually impaired.

Vantage is an intelligent wearable "brain box" designed to help users navigate the physical world safely and independently. Built on the Raspberry Pi 5 and accelerated by the Hailo-8 AI processor, it detects obstacles such as curbs, potholes, vehicles, and environmental structures in real-time, providing actionable spatial feedback.

---

## Technical Specifications

| Component        | Choice                         | Rationale                                                  |
|-----------------|--------------------------------|------------------------------------------------------------|
| Processor        | Raspberry Pi 5 (8GB)           | High-speed throughput for real-time YOLO processing         |
| AI Accelerator   | Raspberry Pi AI HAT+           | 13 TOPS performance via the Hailo-8 chip                    |
| Vision System    | USB Mini-Module                | Improved durability over ribbon cable-based cameras         |
| Framework        | Flutter                        | Cross-platform support for Android and iOS                  |
| Model            | YOLOv26n                         | Optimized for edge inference   |

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

### Phase 4: Hardware Integration (Current)

- Finalized the "Brain Box" assembly
- Transitioned from Pi Camera ribbon cables to a USB camera module to improve reliability during motion
- Resolved thermal constraints by repositioning the cooling system

### Phase 3: CAD and Enclosure Design

- Learned Autodesk Fusion 360 from scratch
- Addressed component fitting challenges by breaking external references
- Applied a 1.1x clearance factor to ensure proper internal fitment

### Phase 2: Data Science and Model Training

- Aggregated datasets from Roboflow
- Migrated from Google Colab to Kaggle for improved GPU performance
- Achieved 83% mAP@50, validating readiness for real-world testing

### Phase 1: Foundation and Application Development

- Initially developed in Kotlin, later transitioned to Flutter for cross-platform support
- Built initial user interface
- Integrated a temporary TensorFlow Lite model for early-stage validation

---

## Conclusion

Vantage represents a convergence of edge AI and robust hardware with human-centered design. By combining efficient hardware with optimized machine learning models, it aims to deliver real-time environmental awareness in a compact, wearable form factor.

This project continues to evolve toward robust real-world deployment and accessibility impact.
