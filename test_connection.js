// Test API connection
const axios = require('axios');

async function testConnection() {
  try {
    // Test login
    console.log('Testing login...');
    const loginResponse = await axios.post('http://localhost:4000/api/login', {
      username: 'admin',
      password: 'admin123'
    });
    
    console.log('Login successful:', loginResponse.data);
    const token = loginResponse.data.token;
    
    // Test villages endpoint
    console.log('Testing villages endpoint...');
    const villagesResponse = await axios.get('http://localhost:4000/api/villages', {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    console.log('Villages:', villagesResponse.data);
    console.log('Connection test successful!');
    
  } catch (error) {
    console.error('Connection test failed:', error.response?.data || error.message);
  }
}

testConnection();
