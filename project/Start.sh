#set -e
#
#echo "Starting Docker containers..."
#docker-compose up -d
#sleep 5
#echo "Copying JSON data into MongoDB container..."
#docker cp data/us-states-array.json mongodb:/us-states-array.json
#docker exec mongodb mongoimport --db usmap --collection states --file /us-states-array.json --jsonArray
#
#echo "Installing backend dependencies..."
#cd backend && npm install
#cd ..
#
#echo "Installing frontend dependencies..."
#cd frontend && npm install
#cd ..
#
#echo "Starting backend server..."
#cd backend
#npm run start &
#
#echo "Starting frontend server..."
#cd ../frontend
#npm run dev &
#
#echo "All services started successfully"
#wait


#!/bin/bash
set -e

echo "Starting Docker containers..."
docker-compose up -d
sleep 5
docker exec mongodb mongosh usmap --eval "db.states.deleteMany({})"
docker cp data/us-states-array.json mongodb:/us-states-array.json
docker exec mongodb mongoimport --db usmap --collection states --file /us-states-array.json --jsonArray


echo "All services started successfully!"
echo "Frontend running at: http://localhost:5173"
echo "Backend running at: http://localhost:4000/graphql"
