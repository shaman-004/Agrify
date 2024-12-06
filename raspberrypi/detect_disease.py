import requests

BACKEND_URL = "http://192.168.1.10:8000"

# Upload an image for detection
with open("captured_image.jpg", "rb") as file:
    response = requests.post(f"{BACKEND_URL}/run-detection/", files={"file": file})
    print(response.json())

# Send additional detection data (optional)
detection_data = {
    "cluster_id": "Cluster1",
    "disease_detected": True,
    "message": "Disease detected in Cluster1."
}
requests.post(f"{BACKEND_URL}/disease-detected", json=detection_data)
