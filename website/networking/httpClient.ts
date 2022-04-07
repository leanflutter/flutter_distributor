import axios from "axios";

const httpClient = axios.create({
  baseURL: "https://biyi-api.thecode.me",
  // baseURL: "http://localhost:8080",
});

export default httpClient;
