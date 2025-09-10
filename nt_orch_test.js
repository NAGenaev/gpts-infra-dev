import http from 'k6/http';
import { check, sleep } from 'k6';

// 🎯 Настройки: 10 000 запросов, параллельно 20 VU
export const options = {
  scenarios: {
    fixed_requests: {
      executor: 'per-vu-iterations',
      vus: 50,              // количество виртуальных пользователей
      iterations: 10000,      // число запросов на каждого VU
      maxDuration: '10m',   // лимит по времени, чтобы не зависло
    },
  },
};

function guid() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    let r = Math.random() * 16 | 0;
    let v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

export default function () {
  const url = 'http://gpts.local:8083/api/transfers';

  const payload = JSON.stringify({
    transferId: guid(),
    fromUserId: guid(),
    toUserId: guid(),
    amount: Math.floor(Math.random() * 1000) + 1,
    currency: 'RUB',
  });

  const params = {
    headers: { 'Content-Type': 'application/json' },
  };

  const res = http.post(url, payload, params);


  check(res, {
    'status is 202': (r) => r.status === 202,
  });
  //sleep(0.1);
}
