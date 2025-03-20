set -e

echo "Starting Docker containers..."
docker-compose up -d

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
echo "Frontend running at: http://localhost:5173"
echo "Backend running at: http://localhost:4000/graphql"

wait
