from pydantic import BaseModel

class DetectionData(BaseModel):
    cluster_id: str
    disease_detected: bool
    message: str
