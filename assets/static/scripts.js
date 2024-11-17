const apiUrl = '{{API_URL}}';

async function fetchVisitorCount() {
    try {
        const response = await fetch(apiUrl, {
            cache: 'no-store'
        });
        const data = await response.json();

        console.log("Fetched count:", data.visitorCount);
        document.getElementById('visitor-count').innerText = `Visitor Number: ${data.visitorCount}`;
    } catch (error) {
        console.error('Failed to fetch visitor count:', error);
        document.getElementById('visitor-count').innerText = 'Error loading count';
    }
}

fetchVisitorCount();
