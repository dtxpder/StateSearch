set -e

echo "Starting Docker containers..."
docker-compose up -d

echo "Copying JSON data into MongoDB container..."
docker cp data/us-states-array.json mongodb:/us-states-array.json
docker exec mongodb mongoimport --db usmap --collection states --file /us-states-array.json --jsonArray

echo "Installing backend dependencies..."
cd backend && npm install
cd ..

echo "Installing frontend dependencies..."
cd frontend && npm install
cd ..

echo "Starting backend server..."
cd backend
npm run start &

echo "Starting frontend server..."
cd ../frontend
npm run dev &

echo "All services started successfully"
wait
