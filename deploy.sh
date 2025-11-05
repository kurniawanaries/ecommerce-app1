#!/bin/bash

ssh -p "${SERVER_PORT}" "${SERVER_USERNAME}"@"${SERVER_HOST}" -i key.txt -t -t -o StrictHostKeyChecking=no << 'ENDSSH'
cd ~/ecommerce
cat .env
set +a
source .env
start=$(date +"%s")

echo "🔐 Logging into Docker Hub..."
docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_TOKEN

echo "📦 Pulling latest image..."
docker pull kurniawanaries/ecommerce-app1:$IMAGE_TAG

if [ "$(docker ps -qa -f name=$CONTAINER_NAME)" ]; then
    if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
        echo "🛑 Stopping and removing existing container..."
        docker stop $CONTAINER_NAME
        docker rm $CONTAINER_NAME
    fi
fi

echo "🚀 Starting new container..."
docker run -d --restart unless-stopped \
  -p $APP_PORT:$APP_PORT \
  --env-file .env \
  --name $CONTAINER_NAME \
  -e SPRING_PROFILES_ACTIVE=github \
  kurniawanaries/ecommerce-app1:$IMAGE_TAG

docker ps
exit
ENDSSH

if [ $? -eq 0 ]; then
  echo "✅ Deployment successful!"
else
  echo "❌ Deployment failed!"
  exit 1
fi

end=$(date +"%s")
diff=$(($end - $start))
echo "⏱ Deployed in: ${diff}s"
