import { WagmiConfig, createClient, chain, configureChains, useAccount } from "wagmi";
import { ConnectKitProvider, ConnectKitButton, getDefaultClient } from "connectkit";
import { ConnectInfo } from "./conponents/Button/Connect";
import { Play } from "./conponents/Button/Play";
import { Finalize } from "./conponents/Button/Finalize";
import { ClaimReward } from "./conponents/Button/ClaimReward";
import { alchemyProvider } from "wagmi/providers/alchemy";
import { MetaMaskConnector } from "wagmi/connectors/metaMask";
import { Component } from "react";

const alchemyId = process.env.ALCHEMY_ID;

const { provider, chains } = configureChains(
    [chain.goerli, chain.optimism, chain.arbitrum],
    [
        alchemyProvider({ apiKey: alchemyId }),
    ],
);

const client = createClient({
    autoConnect: true,
    connectors: [
        new MetaMaskConnector({
            chains: chains,
            options: {
                qrcode: true,
            },
        }),
    ],
    provider,
});

class App extends Component {
    constructor() {
        super()
        this.state = {
            "name": "duke"
        }
    }
    render() {
        return (
            <WagmiConfig client={client}>
                <ConnectKitProvider>
                    <ConnectKitButton />
                </ConnectKitProvider>
                <ConnectInfo />
                <Play />
                <Finalize />
                <ClaimReward />
            </WagmiConfig>
        );
    }
}

export default App