import React, { useState, useEffect } from "react";
import { ethers } from "ethers";
import abi from "./abi.json";

export default function GovernanceApp() {
  const contractAddress = "0x64bC644e2225D7e6B75A8543221556e0E1A5a955";
  const [contract, setContract] = useState(null);
  const [errorMessage, setErrorMessage] = useState("");
  const [defaultAccount, setDefaultAcount] = useState("");
  const [connButtonText, setConnButtonText] = useState("Connect Wallet");

  // checks if the window.ethereum object exists. if it does,
  // request for connected accounts and set the first account as the
  // default account
  const connectWalletHandler = () => {
    if (window.ethereum) {
      window.ethereum
        .request({ method: "eth_requestAccounts" })
        .then((result) => {
          accountChangedHandler(result[0]);
          setConnButtonText("Wallet Connected");
        });
    } else {
      setErrorMessage("Install MetaMask!");
    }
  };

  // handles UI re-rendering on account change
  const accountChangedHandler = (newAccount) => {
    setDefaultAcount(newAccount);
  };

  window.ethereum.on("accountsChanged", accountChangedHandler);

  const updateEthers = () => {
    let Provider = new ethers.providers.Web3Provider(window.ethereum);

    let Signer = Provider.getSigner();

    let contract = new ethers.Contract(contractAddress, abi.abi, Signer);

    setContract(contract);
  };

  return (
    <>
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
        }}
      >
        <h4>Governance App</h4>
        <button onClick={connectWalletHandler}>{connButtonText}</button>
        <div>
          <h3>Address:{defaultAccount}</h3>
        </div>
        {errorMessage}
      </div>
    </>
  );
}
