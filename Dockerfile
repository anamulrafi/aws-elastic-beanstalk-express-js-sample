FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
# Assignment requires npm install --save
RUN npm install --save || true
COPY . .
EXPOSE 8081
CMD ["node", "app.js"]
