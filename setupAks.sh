export https_proxy=http://PITC-Zscaler-EMEA-Amsterdam3PR.proxy.corporate.ge.com
az login
az aks install-cli
aks list -o table
az aks get-credentials --resource-group tailspin-space-game-rg --name tailspinspacegame-18698
kubectl create namespace tailspinspacegame-test
kubectl create namespace tailspinspacegame