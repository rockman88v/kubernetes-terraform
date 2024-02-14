# Tác giả
**Trịnh Quốc Việt** - Senior Devops

Viblo: https://viblo.asia/u/rockman88v

![](https://i.upanh.org/2024/02/14/VietTQ180x1807f55513fe356686e.png)

# Giới thiệu
## Cài đặt
***Repo này giúp các bạn dựng một cụm single-master kubernetes trên môi trường cloud AWS bằng terraform, script và argocd:***
- Hạ tầng trên AWS (gồm VM - EC2, network, firewall..) được tạo bằng terraform.
- Các VM (EC2) được tạo trong public-subnet của default VPC
- Việc cài đặt và thiết lập kubernetes (và một vài ứng dụng khác như haproxy, argocd) được thực hiện bằng script khi bootstrap các VM.
- Từ ArgoCD ta sẽ tạo các argocd-application giúp cài đặt các ứng dụng khác một cách tự động như metric-server, kubernetes-dashboard, cert-managers...
## Yêu cầu
Để dựng được lab này các bạn cần có tài khoản AWS và một chút kiến thức cơ bản về AWS và cần đảm bảo:
- Trong aws region mà bạn dựng lab phải có sẵn default VPC (nếu chưa có thì cần tạo)
- Cần tạo aws access-key để sử dụng cho terraform
- Cần tạo key pair để SSH vào các VM sau khi tạo
- Cài đặt terraform và aws-cli trên máy cá nhân của bạn

# Dựng lab
Chi tiết hơn các bạn có thể tham khảo ở đây:
https://viblo.asia/p/cai-dat-kubernetes-bang-terraform-voi-1-cau-lenh-38X4E9qB4N2
## Cấu hình AWS CLI	
```
$ aws configure
AWS Access Key ID [None]: XXXXXXXXXXX
AWS Secret Access Key [None]: XXXXXXXXXXXXXXXXXXXXXXXXX
Default region name [None]: ap-southeast-1
Default output format [None]: json
```
## Cấu hình tham số khi chạy terraform
Cấu hình tham số ở file `kubernetes/terraform.tfvars`:
- **cluster_prefix** => Dùng làm prefix cho các resource tạo trên AWS cho cluster này, tránh conflict khi tạo nhiều cụm cluster
- **keypair_name** => Tên key pair sử dụng cho các EC2
- **master_instance_type** => Chọn instance type cho master node. Với mục đích học tập và làm lab thì dùng t3.small (2CPU + 2GB RAM) là đủ
- **worker_instance_type** => Chọn instance type cho worker node. Bạn cần chạy càng nhiều workload thì có thể tăng cấu hình của worker node lên
- **master_instance_name** => Set tên cho các ec2 master trên web console
- **worker_instance_name** => Set tên cho các ec2 worker trên web console
- **region** => Lựa chọn aws region để cài lab
- **number_of_workers** => Lựa chọn số lượng worker node muốn tạo cho cluster này. Các worker có cùng cấu hình được set ở tham số worker_instance_type bên trên
- **included_components** => Cho phép bạn lựa chọn các thành phần sẽ được cài đặt kèm khi cài kubernetes
## Thực hiện cài đặt
Cài đặt lab trên AWS:
````bash
cd kubernetes-terraform/kubernetes
terraform init
terraform plan
terraform apply --auto-approve
````
Khi dựng lab xong sẽ có output là public IP của master-node, bạn sẽ dùng nó để cấu hình file host trên máy cá nhân để truy cập vào các ứng dụng của bạn thông qua domain:
````yaml
Outputs:
control_plane_public_ip = [
  "47.129.57.49",
]
worker_node_public_ip = [
  "13.215.209.61",
  "13.250.115.120",
]
````

Xóa lab trên AWS:
````bash
cd kubernetes-terraform/kubernetes
terraform destroy --auto-approve
````
## Kết quả

Mặc định lab này sẽ giúp bạn cài đặt ArgoCD, bạn có thể kết nối qua domain. Mặc định có 2 domain bạn cần khai trên máy cá nhân như sau (cập nhật IP theo kết quả khi dựng lab):
````
47.129.57.49 argocd.viettq.com
47.129.57.49 dashboard.viettq.com
````
### Truy cập vào argocd
Sau khi khai domain, các bạn vào web kết nối vào domain `argocd.viettq.com` và sử dụng user `admin`, password lấy từ câu lệnh sau (chạy trên master-node):
````
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d;echo
````
![](https://images.viblo.asia/a411d4ac-ef05-4a8c-b24c-189599c1e51f.png)
### Truy cập vào kubernetes-dashboard
Sau khi khai domain, các bạn vào web kết nối vào domain `dashboard.viettq.com` và sử dụng token lấy từ câu lệnh sau (chạy trên master-node):
````
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d;echo
````
![](https://images.viblo.asia/b926baa5-ca15-40f7-b11a-c0855d3e01c2.png)
