from ultralytics import YOLO  # Replace with your model library

class DetectionModel:
    def __init__(self, model_path: str):
        self.model = YOLO(model_path)

    def detect(self, image_path: str):
        results = self.model(image_path)
        detections = results[0].boxes.data  # Process detection results
        return detections
