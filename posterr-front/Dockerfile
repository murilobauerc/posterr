FROM node:20-alpine3.17

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 5173

RUN npm install -g serve

CMD ["npm", "run", "dev"]
