const apiUrl = '{{API_URL}}';

async function fetchVisitorCount() {
    try {
        const response = await fetch(apiUrl, {
            cache: 'no-store'
        });
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const bodydata = await response.json();

        // Assuming the response is already JSON, no need for JSON.parse
        const data = bodydata;

        // Log the response data to check its structure
        console.log("Response Data: ", data);

        if (data.visitorCount!== undefined) {
            document.getElementById('visitor-count').innerText = `Visitor Number: ${data.visitorCount}`;
        } else {
            console.error('Visitor count not found in the response data');
        }
    } catch (error) {
        console.error('Error fetching visitor count:', error);
        document.getElementById('visitor-count').innerText = 'Unable to load visitor count';
    }
}

// Call the function to fetch the visitor count
fetchVisitorCount();