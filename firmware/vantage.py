import cv2
import time
import sys
from ultralytics import YOLO

def main():
    print("Starting Vantage firmware...")
    
    print("Loading Model...")
    model = YOLO('best.pt') 
    
    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    
    if not cap.isOpened():
        print("Couldn't find webcam.")
        sys.exit(1)
        
    print("Camera Connected!")
    time.sleep(2.0)

    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                print("Failed to grab the frame")
                break
            results = model(frame, conf=0.5, verbose=False) 
            
            for box in results[0].boxes:
                class_id = int(box.cls[0])           
                class_name = model.names[class_id]   
                confidence = float(box.conf[0])                      
                print(f"Detected: {class_name} ({confidence:.2f})", flush=True)

            annotated_frame = results[0].plot()
            
            cv2.imshow("Vantage Vision - Debug View", annotated_frame)
            
            if cv2.waitKey(1) & 0xFF == ord('q'):
                print('Shutting down...')
                break
                
    except KeyboardInterrupt:
        print('Interrupted by user')
    finally:
        cap.release()
        cv2.destroyAllWindows()
        print("Camera released.")

if __name__ == '__main__':
    main()