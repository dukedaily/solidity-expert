from etherscan.contracts import Contract

contract_dir = "tmp-contract.sol"
address = '0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359'

def get_contract_from_blockchain(address, key_file=None):

    key = get_api_key(key_file)
    api = Contract(address=address, api_key=key)
    sourcecode = api.get_sourcecode()
    with open(contract_dir, "w") as contract_file:
        contract_file.write(sourcecode[0]['SourceCode'])

    return contract_dir

def get_api_key(key):
    try:
        with open(key, mode='r') as key_file:
            return key_file.read()
    except FileNotFoundError:
        print("ERROR: api_key.txt was not found. Create an API key in https://etherscan.io/myapikey or type it now.")


