FROM node
COPY package*.json .
RUN yarn
COPY . .
EXPOSE 8080
CMD ["yarn","start"]
