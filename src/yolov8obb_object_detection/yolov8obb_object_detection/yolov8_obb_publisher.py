#!/usr/bin/env python3

from ultralytics import YOLO
import os
import copy
import rclpy
from ament_index_python.packages import get_package_share_directory
from rclpy.node import Node
from sensor_msgs.msg import Image
from cv_bridge import CvBridge

from yolov8_msgs.msg import InferenceResult
from yolov8_msgs.msg import Yolov8Inference

bridge = CvBridge()

class Camera_subscriber(Node):

    def __init__(self):
        super().__init__('camera_subscriber')

        default_model_path = os.path.join(
            get_package_share_directory('yolov8obb_object_detection'),
            'models',
            'best.pt')
        model_path = os.environ.get('YOLO_MODEL_PATH', default_model_path)
        self.get_logger().info(f'Loading YOLO model from: {model_path}')
        self.model = YOLO(model_path)

        self.yolov8_inference = Yolov8Inference()

        self.subscription = self.create_subscription(
            Image,
            '/rgb',
            self.camera_callback,
            10)
        self.subscription 

        self.yolov8_pub = self.create_publisher(Yolov8Inference, "/Yolov8_Inference", 1)
        self.img_pub = self.create_publisher(Image, "/inference_result", 1)

    def camera_callback(self, data):
        img = bridge.imgmsg_to_cv2(data, "bgr8")
        results = self.model(img, conf=0.85)

        self.yolov8_inference.header.frame_id = "inference"
        self.yolov8_inference.header.stamp = self.get_clock().now().to_msg()  # ✅ fixed

        for r in results:
            if r.obb is not None:
                boxes = r.obb
                for box in boxes:
                    self.inference_result = InferenceResult()
                    b = box.xyxyxyxy[0].to('cpu').detach().numpy().copy()
                    c = box.cls
                    self.inference_result.class_name = self.model.names[int(c)]
                    a = b.reshape(1, 8)
                    self.inference_result.coordinates = copy.copy(a[0].tolist())
                    self.yolov8_inference.yolov8_inference.append(self.inference_result)
            else:
                self.get_logger().info("no_results")  # ✅ fixed

        self.yolov8_pub.publish(self.yolov8_inference)
        self.yolov8_inference.yolov8_inference.clear()

        annotated_frame = results[0].plot()
        img_msg = bridge.cv2_to_imgmsg(annotated_frame)
        self.img_pub.publish(img_msg)


def main(args=None):
    rclpy.init(args=args)
    camera_subscriber = Camera_subscriber()
    try:
        rclpy.spin(camera_subscriber)
    except (KeyboardInterrupt, rclpy.executors.ExternalShutdownException):
        pass
    finally:
        camera_subscriber.destroy_node()
        if rclpy.ok():
            rclpy.shutdown()

if __name__ == '__main__':
    main()
