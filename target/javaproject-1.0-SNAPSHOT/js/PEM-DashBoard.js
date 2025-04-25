const ctx = document.getElementById('myChart').getContext('2d');

const data = {
  labels: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'],
  datasets: [{
    label: 'Expenses',
    data: [750, 980, 580, 200, 450, 600, 250, 880, 580, 950],
    borderColor: '#5cb85c', 
    backgroundColor: 'rgba(92, 184, 92, 0.1)', 
    tension: 0.4, 
    pointBackgroundColor: 'white',
    pointBorderColor: '#5cb85c',
    pointRadius: 5,
    pointHoverRadius: 7,
    pointBorderWidth: 2, 
    fill: false 
  }]
};

const config = {
  type: 'line',
  data: data,
  options: {
    responsive: true, 
    scales: {
      x: {
        grid: {
          display: true,
          color: '#EEEEEE',
          lineWidth: 1, 
          drawBorder: false,
        },
        ticks: {
          color: '#888', 
          font: {
            size: 12, 
          }
        }

      },
      y: {
        grid: {
          display: true,
          color: '#EEEEEE', 
          lineWidth: 1, 
          drawBorder: false,
        },
        ticks: {
          stepSize: 250,
          color: '#888', 
          font: {
            size: 12, 
          },
          callback: function(value, index, ticks) {
            return value;
          }
        }
      }
    },
    plugins: {
      legend: {
        display: false, 
      }
    }
  }
};


const myChart = new Chart(ctx, config);

