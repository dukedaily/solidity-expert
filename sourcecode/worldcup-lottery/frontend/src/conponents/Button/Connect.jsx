import { useAccount } from "wagmi";

// Make sure that this component is wrapped with ConnectKitProvider
const ConnectInfo = () => {
  const { address, isConnecting, isDisconnected } = useAccount();
  if (isConnecting) return <div>Connecting...</div>;
  if (isDisconnected) return <div>Disconnected</div>;
  return <div>Connected Wallet: {address}</div>;
};

export {
    ConnectInfo,
}