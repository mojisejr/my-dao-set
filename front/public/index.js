const mintButton = document.querySelector(".mint-nft");
const mintBox = document.querySelector(".mint-box");
const connectWallet = document.querySelector(".connect-wallet");
const address = document.querySelector(".address");
const tokenIdInput = document.querySelector(".tokenId");
const message = document.querySelector(".status");

const polygonRPC = "";
const contractAddress = "0x666Fc939e61Fa43F30651cc2A2735624DfdeA83c";
const abi = ["function mint(address to, uint256 tokenId) payable public"];
//ether;

const _price = "0.001";
let _ethereum;
let _provider;
let _signer;
let _address;
let _contract;

window.addEventListener("load", (async) => {
  if (window.ethereum !== undefined) {
    _ethereum = window.ethereum;
  }
  _provider = new ethers.providers.Web3Provider(_ethereum);
  const address = _signer === undefined ? false : _signer.getAddress();
  if (address) {
    _address.innerHTML = address;
    connectWallet.hidden = true;
    showMintingBox(true);
  } else {
    connectWallet.hidden = false;
    showMintingBox(false);
  }
});

//button handler
connectWallet.addEventListener("click", onConnect);
mintButton.addEventListener("click", onMint);

async function onConnect() {
  await _provider.send("eth_requestAccounts", []);
  _signer = _provider.getSigner();
  _address = await _signer.getAddress();
  address.innerHTML = _address;
  connectWallet.hidden = true;
  _contract = new ethers.Contract(contractAddress, abi, _signer);
  showMintingBox(true);
}

async function onMint() {
  const tokenId = tokenIdInput.value;
  const to = address.textContent;
  try {
    if (tokenId == null || tokenId == undefined) {
      message.innerHTML = "ERROR: Minting failed, invalid token id";
    } else {
      message.setAttribute("style", "color: black");
      message.innerHTML = "Minting...";
      const tx = await mint(to, tokenId);
      tx.wait();
      message.setAttribute("style", "color: lightgreen; background: black;");
      message.innerHTML = "Minting done => " + tx.hash;
    }
  } catch (e) {
    message.setAttribute("style", "color: red");
    message.innerHTML = "ERROR: Minting failed, try again with another tokenId";
  }
}

function showMintingBox(show = false) {
  if (show) {
    mintBox.setAttribute("style", "display:flex");
  } else {
    mintBox.setAttribute("style", "display:none");
  }
}

async function mint(to, tokenId) {
  const mintingPrice = ethers.utils.parseUnits(_price, "ether");
  const tx = await _contract.mint(to, tokenId.toString(), {
    value: mintingPrice,
  });
  return tx;
}
