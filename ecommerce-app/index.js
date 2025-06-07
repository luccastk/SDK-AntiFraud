import IpVerifier from "sdk-antifraud";
import express from "express";

const app = express();
const port = 3000;

const verifier = IpVerifier.init();

app.set("trust proxy", true);

app.get("/", (request, response) => {
  response.send("Hello World!");
});

app.get("/checkout", verifier.middlewareIpVerify(), (req, res) => {
  console.log("Resultado esperado", req.ipVerificationResult);
  res.send("Checkout de verificação de ip");
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
