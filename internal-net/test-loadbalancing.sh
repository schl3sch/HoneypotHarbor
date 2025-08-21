for i in {1..1000}
do
    curl localhost:80
    echo
done

echo "API Test"
sleep 5

for i in {1..1000}
do
    curl localhost:80/api/
    echo
done