FROM hashicorp/terraform:latest

WORKDIR /usr/app/src

COPY scripts.sh ./

CMD ["./scripts.sh"]