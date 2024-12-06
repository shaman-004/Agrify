from fastapi import FastAPI, WebSocket, UploadFile
from pydantic import BaseModel
import os
from ml_model.detection_model import DetectionModel

# Initialize FastAPI app
app = FastAPI()

# YOLOv8 Detection Model
model = DetectionModel("ml_model/model.pt")

# Directory to store temporary uploaded images
os.makedirs("temp", exist_ok=True)

# Store active WebSocket connections
active_connections = []

class DetectionData(BaseModel):
    cluster_id: str
    disease_detected: bool
    message: str

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket endpoint for real-time communication with the Flutter app."""
    await websocket.accept()
    active_connections.append(websocket)
    try:
        while True:
            await websocket.receive_text()  # Keeps the WebSocket connection alive
    except:
        active_connections.remove(websocket)

@app.post("/disease-detected")
async def disease_detected(data: DetectionData):
    """API endpoint to receive disease detection results and broadcast to WebSocket clients."""
    for connection in active_connections:
        await connection.send_json({
            "cluster_id": data.cluster_id,
            "disease_detected": data.disease_detected,
            "message": data.message
        })
    return {"status": "Notification sent"}

@app.post("/run-detection/")
async def run_detection(file: UploadFile):
    """API endpoint to upload an image, run the YOLOv8 model, and return detection results."""
    # Save uploaded image to temp directory
    file_path = f"temp/{file.filename}"
    with open(file_path, "wb") as buffer:
        buffer.write(await file.read())

    # Run detection using the YOLOv8 model
    detections = model.detect(file_path)

    # Example: Broadcast detection results to WebSocket clients
    for connection in active_connections:
        await connection.send_json({
            "cluster_id": "Cluster1",
            "disease_detected": True,
            "message": f"Disease detected in {file.filename}!"
        })

    # Clean up temporary file
    os.remove(file_path)

    return {"detections": detections}
