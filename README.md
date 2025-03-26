# bastiaan/docker-tcpdump

`bastiaan/docker-tcpdump` is a scratch container with a static build of `tcpdump` with capability `CAP_NET_RAW` set.

## Purpose

The main purpose of this container is to perform network capture with minimal permissions and minimal attack surface. 

It runs as non-root user and only needs capability `CAP_NET_RAW`, which is enabled by default.

## Usage

### In Docker

```
docker run --network <TARGET-NETWORK> -ti --rm --cap-drop=ALL --cap-add=NET_RAW ghcr.io/bastiaanb/docker-tcpdump
```

### In Kubernetes

Run as an ephemeral container attached to your target Pod.

#### Running as root
```
kubectl debug -n <targer-namespace> <target-pod> -ti --image=ghcr.io/bastiaanb/docker-tcpdump
```

This runs the `tcpdump` as root. 

#### Running without root 

If your target pod has a `SecurityContext` that does not permit this (e.g. has `runAsNonRoot: true`),
you can define a custom profile to run the ephemeral container with minimal privileges:

```
cat > custom-profile.yaml <<EOF
securityContext:
  runAsUser: 1000
  capabilities:
    add:
      - NET_RAW
    drop:
      - ALL
EOF

kubectl debug -n <target-namespace> <target-pod> -i --image=ghcr.io/bastiaanb/docker-tcpdump --profile=general --custom=custom-profile.yaml -- /tcpdump -f "tcp port 8080"
```

#### Running detached

Running in detached mode makes it easier to save a raw capture locally, for further inspection by tools like `wireshark`. 
Start the container, running `pause`.

```
kubectl debug <target-pod> --image=ghcr.io/bastiaanb/docker-tcpdump -c capture --profile=general --custom=custom-profile.yaml -- /pause
```

Then exec to run tcpdump
```
kubectl exec -i <target-pod> -c capture -- /tcpdump -i eth0 -f "tcp port 8080" -w - > tcp-8080.cap
<ctrl-c>
wireshark tcp-8080.cap
```

## Thanks

[tcpdump](https://www.tcpdump.org/) the main star of this container.

[Ksniff](https://github.com/eldadru/ksniff/) wonderful kubectl plugin to make packet capture in your pods easy. Does not work with non privileged containers however, prompting this container image.

[setcap-static](https://github.com/sjinks/setcap-static) minimal `setcap` implementation.
