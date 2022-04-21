import { useState } from "react";
import { ethers } from "ethers";

const WalletCard = () => {
  const [errorMessage, setErrorMessage] = useState("");
  const [defaultAccount, setDefaultAcount] = useState("");
  const [userBalance, setUserBalance] = useState("");
  const [connButtonText, setConnButtonText] = useState("Connect Wallet");

  const connectWalletHandler = () => {
    if (window.ethereum) {
      window.ethereum
        .request({ method: "eth_requestAccounts" })
        .then((result) => {
          accountChangedHandler(result[0]);
        });
    } else {
      setErrorMessage("Install MetaMask");
    }
  };

  const accountChangedHandler = (newAccount) => {
    setDefaultAcount(newAccount);
    getUserBalance(newAccount.toString());
  };

  const getUserBalance = (address) => {
    window.ethereum
      .request({ method: "eth_getBalance", params: [address, "latest"] })
      .then((balance) => {
        setUserBalance(ethers.utils.formatEther(balance));
      });
  };

  const chainChangedHandler = () => {
    window.location.reload();
  };
  window.ethereum.on("accountsChanged", accountChangedHandler);
  window.ethereum.on("chainChanged", chainChangedHandler);
  return (
    <>
      <div>
        <h4>{"Connection to MetaMask using window.ethereum methods"}</h4>
        <button onClick={connectWalletHandler}>{connButtonText}</button>
        <div>
          <h3>Address:{defaultAccount}</h3>
        </div>
        <div>
          <h3>Balance: {userBalance}</h3>
        </div>
        {errorMessage}
      </div>
    </>
  );
};

export default WalletCard;
