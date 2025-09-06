//тест на 2 млн транзакций из пула 1 млн крест на крест
// k6 run test.js --insecure-skip-tls-verify
// 
// 
import http from 'k6/http';
import { check, sleep } from 'k6';

const startNumber = 40817810111322211n;
const totalTransactions = 2_000_000; // Увеличили до 2 млн
const vus = 200;

export const options = {
  scenarios: {
    transactions: {
      executor: 'per-vu-iterations',
      vus: vus,
      iterations: totalTransactions / vus, // count итераций/VU
      maxDuration: '1m', // Увеличили максимальное время выполнения
    },
  },
  thresholds: {
    'http_req_duration': ['p(95)<1000'],
    'http_req_failed': ['rate<0.01'],
  },
  discardResponseBodies: true,
};

export default function () {
  //console.log(`TLS_SKIP_VERIFY: ${__ENV.K6_TLS_SKIP_VERIFY}`);
  const vuIterations = totalTransactions / vus;
  const globalIndex = BigInt((__VU - 1) * vuIterations + __ITER);

  // Используем модуль от исходного общего количества транзакций (1 млн),
  // чтобы номера счетов повторялись в том же диапазоне
  const modIndex = globalIndex % BigInt(1_000_000);
  
  const sender = (startNumber + modIndex).toString();
  const receiver = (startNumber + BigInt(1_000_000 - 1) - modIndex).toString();

  const amount = 1;

  const payload = JSON.stringify({
    fromUserId: sender,
    toUserId: receiver,
    amount: amount,
    currency: "RUB"
  });

  const res = http.post('https://gpts.local:8443/api/transfer', payload, {
    headers: { 
      'Content-Type': 'application/json',
      'X-API-Key': 'eyJhbGciOiJIUzI1NiJ9.eyJhcGlJZCI6ImdwdHMiLCJleHAiOjE3MDAwMDAwMDB9.W_kmzcvOSb2xXNgX65-VEukf-mR_EEO7m34eCIxxuVE'
    },
    timeout: '30s',
  });

  check(res, {
    '📦 статус 201': (r) => r.status === 201,
  });

  if (res.status !== 201) {
    console.error(`❌ Ошибка при транзакции: ${res.status} → ${payload}`);
  }

  //sleep(0.5);
  //sleep(0.001);
}