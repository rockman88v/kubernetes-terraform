echo "#############################"
echo "install-haproxy.sh"
sudo apt update
sudo add-apt-repository ppa:vbernat/haproxy-2.7 -y
sudo apt update
sudo apt install haproxy=2.7.\* -y
sudo systemctl status haproxy
haproxy -v




sudo tee -a /etc/haproxy/haproxy.cfg > /dev/null << EOF
frontend frontend_https
        bind :80 
        bind *:443 ssl crt /etc/haproxy/certs/       
        mode http
        option httpclose
        option forwardfor
        http-request set-header X-Forwarded-Proto http unless { ssl_fc } or { req.hdr(X-Forwarded-Proto) https }
        http-request set-header X-Forwarded-Proto https if { ssl_fc }
        http-request redirect scheme https code 301 if !{ ssl_fc }

        #reqadd X-Forwarded-Proto:\ https        
        cookie  SRVNAME insert indirect nocache
        default_backend backend_ingress       

backend backend_ingress
        mode    http
        stats   enable
        stats   auth username:password
        balance roundrobin
        server  master1 MASTER_IP:30080 cookie p1 weight 1 check inter 2000
EOF

privateip=`hostname -i |cut -d " " -f1`
echo "privateip=$privateip"
sudo sed -i "s/MASTER_IP/$privateip/g" /etc/haproxy/haproxy.cfg
sudo tail -25 /etc/haproxy/haproxy.cfg

sudo mkdir -p /etc/haproxy/certs
sudo tee /etc/haproxy/certs/viettq.pem > /dev/null << EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA3a0FCeoWRfRxR1MXPwPHenQfcTbAdALtYmjjchPnnvwx5Y+x
unfMvGMLFOcynL4/a2FO8QBNzbRBDhlQGDHchCBVrP4IhZYP6ByQZuwAKgPpfPLs
sMZvnW8hLQbgfwDkHS1uQlcCh3Mgg7CiKplz+Sr74zPbULcHiRM8X+4ShL9W/KM7
KaSIk96xiAYtHN1BwyjQNrucTwkLYZeWjk609lhVAKScCZYkw47aeQ+oT/drks5P
OcKIZgw2QVPV9D3hDLSBqM+57wzOb/TPpO3EXpH2TODBPRU/TNabv/sGnaG7Q5Y+
IAwBReVJB0f4ugnWZTGwwxaj7Q1VgAtfZdIJ2QIDAQABAoIBAHwh9i9eGUjlIEX7
fon3+M1Wl4DTUyPju8Ce0bbA9LQvr1VIiRLNISXhJIR5Dvt9AZCE9iq4q9jj9oYJ
oLNbwItwe+mae3Uq2g91Z1trDpB4jlg8xFQdWsVDRMWtEyureRHprdOSW8Uzr+Ju
l/DY63t9GX5aPJbPV3XoAqgJbe9NF26KX8pICp4E+/G2GAfCUhc5U5ecZZ3/9wLu
csydi9mjCf8Bd8U81K7hOcD84D/wN1OMeh+0U3Wh6qaXBnJx3YwEyQCwxiidP1Y+
1QD4vdk4jCXjb3jTqADqilLq80GGhEXqs5PEGo26WxyaDf4fwQMHsHeXKerv8Axw
RdtMPk0CgYEA8+c2pgQIcZHuqoVfxXRdXMrCQ3uNrYIQIKb3BxeRkdXbJ6z/7RYE
+45gHF5spqo6hYUlASt5bbxLR4K6YatOqnqnx/FJcnvYCVCnym6u+ZbTj4ov56Ul
zjcYx6UBbYteaOTyQ1OZz0XuNgepss5x50HbfAPVd5BnDZZ7BBwt27sCgYEA6KuX
Ny/kndjG5/TxTCd33dEDV9QBgpr1r+WfOtzMIbPdWmc2uj9BfEaoQuJmyKobvrSM
b1XfqnIiT5kfFjqMZVtrwwTkqTKEl8iyYAP5MneBwmWVIEwKBvXKBv1audUtu8Tc
tZb61RsoK4oJBktCckZtKp3Q2PldqhB4z8jHdXsCgYA3ujZ0TCuZt1wuvfaZ6PKE
BxfHz20ZncQNkdiTWEE8bv553D9FbmiJCYjQMorksbRZWYiQ8dv2xLT2i9oGAtwg
e5HmTy0W6VD9H96WlB+Ki3mfLFWxubwfl9sjkoH3A4b4tIbd9zYHc9Tvp2SQpDbG
PffmKAIYJXhGVIGa+M1JjQKBgAv4qDMit7SXbsSIidHNRhGXq4BdXCaIKpP+UI8K
xUYGpyD7pok2r/vg9s9aLsesWPka+Q7RcEyoyrMlwb+3C3o7lfPW0J0UCFZ28RaX
nb7G/1otN9sNjoaFJvvtFTnyigPbQS/msMk+OHblB0nXnXebwAotTI2dZwBVEKJA
RmL5AoGBAPMq8wphpu6sERP4H6thYXb7Vm5zSlWpbbJemgencmfwccfQ4HFDsRJA
54hWaTTZoj/DGc6SYvBDNVtesWwLD87OtV0WTLBq08X2bIyjFGATMA7qMZi8QYJN
MLeGg3OnSggBHUglgsUsAVYpDPZGt1jIm3gRQzGSInPnoLptayRz
-----END RSA PRIVATE KEY-----
-----BEGIN CERTIFICATE REQUEST-----
MIIDADCCAegCAQAwUDELMAkGA1UEBhMCVk4xCzAJBgNVBAgMAkhOMQswCQYDVQQH
DAJITjEWMBQGA1UECwwNVmlldFRRX0RFVk9QUzEPMA0GA1UEAwwGdmlldHRxMIIB
IjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3a0FCeoWRfRxR1MXPwPHenQf
cTbAdALtYmjjchPnnvwx5Y+xunfMvGMLFOcynL4/a2FO8QBNzbRBDhlQGDHchCBV
rP4IhZYP6ByQZuwAKgPpfPLssMZvnW8hLQbgfwDkHS1uQlcCh3Mgg7CiKplz+Sr7
4zPbULcHiRM8X+4ShL9W/KM7KaSIk96xiAYtHN1BwyjQNrucTwkLYZeWjk609lhV
AKScCZYkw47aeQ+oT/drks5POcKIZgw2QVPV9D3hDLSBqM+57wzOb/TPpO3EXpH2
TODBPRU/TNabv/sGnaG7Q5Y+IAwBReVJB0f4ugnWZTGwwxaj7Q1VgAtfZdIJ2QID
AQABoGswaQYJKoZIhvcNAQkOMVwwWjAJBgNVHRMEAjAAMAsGA1UdDwQEAwIF4DBA
BgNVHREEOTA3ggwqLnZpZXR0cS5jb22CFCoubW9uaXRvci52aWV0dHEuY29tghEq
LmRlbW8udmlldHRxLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAESIlJcAbeCulkeuf
wxJeJopQKatMJxcs5r889YHzMJvksa/nhC5grTaTOb9vnH8kuTiwYDDR3bbP6asD
17gXcjO5LwsiWso8Hu7QrmRdXP1POdX4SqQgckg3Y6lCBVwQitvjOxybIChj7Q3C
zLVp6Npkq/pKo0M1XWQ/0/+H2COEB8Bi4ExSBfEEGLTqnacV4Ob20rLhrvVgdKSy
Ec5h2wvpnxImz4l5H2vznomgMrBDV23arKE3F+icPcLAx58JsOxFmuDwTTHHhbjP
o9UPAqwHuiMIh0mllWyzRjxu+VqdUOwbpw/aNkAmDAtw5TePmWs4kHOTvKo1VThg
7pZ17A==
-----END CERTIFICATE REQUEST-----
-----BEGIN CERTIFICATE-----
MIIDwzCCAqugAwIBAgIUNwG+67jr9kDjKPVin2CW03xwhVEwDQYJKoZIhvcNAQEL
BQAwgYgxCzAJBgNVBAYTAlZOMQswCQYDVQQIDAJITjELMAkGA1UEBwwCSE4xEjAQ
BgNVBAoMCVZpZXRUUS1DQTESMBAGA1UECwwJVmlldFRRLUNBMRIwEAYDVQQDDAl2
aWV0dHEtY2ExIzAhBgkqhkiG9w0BCQEWFHJvY2ttYW44OHZAZ21haWwuY29tMB4X
DTI0MDIxMjE4MDc1NFoXDTM0MDIwOTE4MDc1NFowUDELMAkGA1UEBhMCVk4xCzAJ
BgNVBAgMAkhOMQswCQYDVQQHDAJITjEWMBQGA1UECwwNVmlldFRRX0RFVk9QUzEP
MA0GA1UEAwwGdmlldHRxMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
3a0FCeoWRfRxR1MXPwPHenQfcTbAdALtYmjjchPnnvwx5Y+xunfMvGMLFOcynL4/
a2FO8QBNzbRBDhlQGDHchCBVrP4IhZYP6ByQZuwAKgPpfPLssMZvnW8hLQbgfwDk
HS1uQlcCh3Mgg7CiKplz+Sr74zPbULcHiRM8X+4ShL9W/KM7KaSIk96xiAYtHN1B
wyjQNrucTwkLYZeWjk609lhVAKScCZYkw47aeQ+oT/drks5POcKIZgw2QVPV9D3h
DLSBqM+57wzOb/TPpO3EXpH2TODBPRU/TNabv/sGnaG7Q5Y+IAwBReVJB0f4ugnW
ZTGwwxaj7Q1VgAtfZdIJ2QIDAQABo1wwWjAJBgNVHRMEAjAAMAsGA1UdDwQEAwIF
4DBABgNVHREEOTA3ggwqLnZpZXR0cS5jb22CFCoubW9uaXRvci52aWV0dHEuY29t
ghEqLmRlbW8udmlldHRxLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAPZ8ipIoJEsRs
D894prjO9ujmDgr9kK1Y9fPEGFWCpUBYUHg0QVHhUnBYs6GwrmJgENlnpfhZTO7z
M3jHzSx7F0Ov8V6pKDX5ZvpuSUD0SWvOENG6o5n/Rpw56MpOY5SZTEoEgy1x1BJ2
Ym1EsfK8MaskShmXU97rGIPQ46WQJSlBuDz62wT5Fiq2yYzrEdVmMUDFpKKr3MnA
kWN08aqr+7XgSLNXCrEtkN5wMbJC0fQ8/CXzULSfIGjGxH03h0G1gw7qPHfzTrkk
Sbt6de2v/oHQcpxXnbPrnWiI0rMDTmvldnSIgnhxOQdRRigMfKy776qvVC7V45Ex
Bxg964yZ7g==
-----END CERTIFICATE-----
EOF

sudo service haproxy restart
echo "haproxy status after installation"
sudo service haproxy status