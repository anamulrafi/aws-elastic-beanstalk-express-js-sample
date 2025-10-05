FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
# Assignment requires npm install --save (kept as requested)
RUN npm install --save || true
COPY . .
EXPOSE 8081
CMD ["node", "app.js"]
