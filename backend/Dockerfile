FROM node:18-alpine

WORKDIR /app

# Cài build tools để compile sqlite3 native binary cho Linux/Alpine
RUN apk add --no-cache python3 make g++

# Copy package files và install dependencies (build native modules cho Linux)
COPY package*.json ./
RUN npm ci --only=production

# Create data directory
RUN mkdir -p /app/data

# Copy source (không copy node_modules từ host Windows)
COPY server.js ./

EXPOSE 3000

CMD ["node", "server.js"]
