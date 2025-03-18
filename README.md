# bastiaan/docker-tcpdump

`bastiaan/docker-tcpdump` is a scratch container with a static build of `tcpdump` with capability `CAP_NET_RAW` set.

## Purpose

The main purpose of this container is to perform network capture with minimal permissions and minimal attack surface. 

It runs as non-root user and only needs capability `CAP_NET_RAW`, which is enabled by default.

## Usage

In Docker

```
docker run --network <TARGET-NETWORK> -i --rm --cap-drop=ALL --cap-add=NET_RAW ghcr.io/bastiaanb/docker-tcpdump
```

In Kubernetes, run as an ephemeral container attached to your target Pod.
```
kubectl debug -n <targer-namespace> <target-pod> -i --image=ghcr.io/bastiaanb/docker-tcpdump
```

This runs the ephemeral pod as root. 

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

kubectl debug -n <targer-namespace> <target-pod> -i --image=ghcr.io/bastiaanb/docker-tcpdump --profile=general --custom=custom-profile.yaml -- -f "tcp port 8080"
```

## Thanks

[tcpdump](https://www.tcpdump.org/) the main star of this container.

[Ksniff](https://github.com/eldadru/ksniff/) wonderful kubectl plugin to make packet capture in your pods easy. Does not work with non privileged containers however, prompting this container image.

[setcap-static](https://github.com/sjinks/setcap-static) minimal `setcap` implementation.
