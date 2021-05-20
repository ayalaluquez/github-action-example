#!/bin/bash

function usage(){
  echo "$(basename $0) usage:"
  echo "    -t type"
  echo "    -n namespace"
  echo "    -gc git_commit"
  echo "    -v values_file"
  echo "    -d docker_image"
  echo "    -e environment"
  echo "    -r region"
  echo "    -p aws_profile"
  echo "    -a application"
  exit 1
}

while [[ $# -gt 1 ]]
do
  case $1 in
    -t)
    # Indicates whether to deploy onto the ECS or the EKS cluster
    TYPE="$2"
    shift
    ;;
    -n)
    # Indicates the namespace to deploy the application when using EKS deployments
    NAMESPACE="$2"
    shift
    ;;
    -gc)
    GIT_COMMIT="$2"
    shift
    ;;
    -v)
    VALUES_FILE="$2"
    shift
    ;;
    -d)
    DOCKER_IMAGE="$2"
    shift
    ;;
    -e)
    ENVIRONMENT="$2"
    shift
    ;;
    -r)
    REGION="$2"
    shift
    ;;
    -p)
    PROFILE="$2"
    shift
    ;;
    -a)
    APPLICATION="$2"
    shift
    ;;
    *)
    usage
    shift
    ;;
  esac
  shift
done

if [ $TYPE = "eks" ]; then
[[ -n ${TYPE} ]] && \
[[ -n ${NAMESPACE} ]] && \
[[ -n ${VALUES_FILE} ]] && \
[[ -n ${GIT_COMMIT} ]] || usage

else
[[ -n ${DOCKER_IMAGE} ]] && \
[[ -n ${ENVIRONMENT} ]] && \
[[ -n ${REGION} ]] && \
[[ -n ${APPLICATION} ]] && \
[[ -n ${PROFILE} ]] || usage
fi

if [ $TYPE = "eks" ]; then
  helm upgrade --namespace ${NAMESPACE} wakingup-api-v2 chart/  --values ${VALUES_FILE} --set global.image.tag=${GIT_COMMIT}
else
  aws cloudformation deploy \
      --stack-name wakingup-${APPLICATION}-deployment \
      --template-file ${APPLICATION}-deployment.yaml \
      --region ${REGION} \
      --profile ${PROFILE} \
      --no-fail-on-empty-changeset \
      --parameter-overrides DockerImage=${DOCKER_IMAGE} \
                            Environment=${ENVIRONMENT}
fi

# APPLICATION: {api, background-job, cron-job, webhooks}
#aws cloudformation deploy \
#    --stack-name wakingup-background-job-deployment \
#    --template-file background-job-deployment.yaml \
#    --region ${REGION} \
#    --profile ${PROFILE} \
#    --no-fail-on-empty-changeset \
#    --parameter-overrides DockerImage=${DOCKER_IMAGE} \
#                          Environment=${ENVIRONMENT}
#
#aws cloudformation deploy \
#    --stack-name wakingup-cron-job-deployment \
#    --template-file cron-job-deployment.yaml \
#    --region ${REGION} \
#    --profile ${PROFILE} \
#    --no-fail-on-empty-changeset \
#    --parameter-overrides DockerImage=${DOCKER_IMAGE} \
#                          Environment=${ENVIRONMENT}
#
#aws cloudformation deploy \
#    --stack-name wakingup-webhooks-deployment \
#    --template-file webhooks-deployment.yaml \
#    --region ${REGION} \
#    --profile ${PROFILE} \
#    --no-fail-on-empty-changeset \
#    --parameter-overrides DockerImage=${DOCKER_IMAGE} \
#                          Environment=${ENVIRONMENT}
