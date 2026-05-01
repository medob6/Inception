/* ─── DOM Ready ─────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', init);

function init() {
  setupParticles();
  setupTypedText();
  setupScrollReveal();
  setupNavigation();
  setupCounters();
}

/* ─── 1. PARTICLE CANVAS ─────────────────────────────── */
function setupParticles() {
  const canvas = document.getElementById('particle-canvas');
  if (!canvas) return;

  const ctx = canvas.getContext('2d');
  let particles = [];
  let animId;

  function resize() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
  }

  function createParticle() {
    return {
      x: Math.random() * canvas.width,
      y: Math.random() * canvas.height,
      vx: (Math.random() - 0.5) * 0.5,
      vy: -Math.random() * 0.5 - 0.2,
      alpha: 0,
      alphaTarget: Math.random() * 0.4 + 0.1,
      size: Math.random() * 1.5 + 0.5,
      life: 0,
      maxLife: Math.random() * 300 + 200,
      color: Math.random() > 0.5 ? '#00d4ff' : '#7c3aed'
    };
  }

  function initParticles() {
    particles = [];
    const count = Math.min(50, Math.floor((canvas.width * canvas.height) / 25000));
    for (let i = 0; i < count; i++) {
      const p = createParticle();
      p.life = Math.random() * p.maxLife;
      particles.push(p);
    }
  }

  function animate() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    particles.forEach(p => {
      const progress = p.life / p.maxLife;
      const alpha = progress < 0.2 ? (progress / 0.2) * p.alphaTarget
                  : progress > 0.8 ? ((1 - progress) / 0.2) * p.alphaTarget
                  : p.alphaTarget;

      ctx.save();
      ctx.globalAlpha = alpha;
      ctx.fillStyle = p.color;
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
      ctx.fill();
      ctx.restore();

      p.x += p.vx;
      p.y += p.vy;
      p.life++;

      if (p.life > p.maxLife) {
        Object.assign(p, createParticle());
        p.x = Math.random() * canvas.width;
        p.y = canvas.height + 10;
        p.life = 0;
      }
    });

    animId = requestAnimationFrame(animate);
  }

  resize();
  initParticles();
  animate();

  window.addEventListener('resize', () => {
    resize();
    initParticles();
  });
}

/* ─── 2. TYPED TEXT ─────────────────────────────────── */
function setupTypedText() {
  const typedEl = document.getElementById('typedText');
  if (!typedEl) return;

  const phrases = [
    'Software Engineer',
    'Systems Programmer',
    'Backend Developer',
    'C / Go Developer',
    '42 Graduate'
  ];

  let pIdx = 0, cIdx = 0, deleting = false;

  function type() {
    const current = phrases[pIdx];
    if (!deleting) {
      typedEl.textContent = current.slice(0, ++cIdx);
      if (cIdx === current.length) {
        deleting = true;
        setTimeout(type, 2200);
        return;
      }
      setTimeout(type, 60);
    } else {
      typedEl.textContent = current.slice(0, --cIdx);
      if (cIdx === 0) {
        deleting = false;
        pIdx = (pIdx + 1) % phrases.length;
        setTimeout(type, 200);
        return;
      }
      setTimeout(type, 40);
    }
  }

  type();
}

/* ─── 3. SCROLL REVEAL ──────────────────────────────── */
function setupScrollReveal() {
  const reveals = document.querySelectorAll('.reveal, .reveal-right');
  if (!reveals.length) return;

  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1 });

  reveals.forEach(el => observer.observe(el));

  // Show initial hero elements immediately
  document.querySelectorAll('#hero .reveal, #hero .reveal-right').forEach(el => {
    el.classList.add('visible');
  });
}

/* ─── 4. NAVIGATION ─────────────────────────────────── */
function setupNavigation() {
  const navToggle = document.getElementById('navToggle');
  const navMenu = document.getElementById('navMenu');
  if (!navToggle || !navMenu) return;

  navToggle.addEventListener('click', () => {
    navMenu.classList.toggle('active');
    navToggle.setAttribute('aria-expanded',
      navToggle.getAttribute('aria-expanded') === 'false' ? 'true' : 'false'
    );
  });

  document.querySelectorAll('.nav-link').forEach(link => {
    link.addEventListener('click', () => {
      navMenu.classList.remove('active');
      navToggle.setAttribute('aria-expanded', 'false');
    });
  });
}

/* ─── 5. STAT COUNTERS ──────────────────────────────── */
function setupCounters() {
  const statEls = document.querySelectorAll('.stat-num');
  if (!statEls.length) return;

  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        animateCounter(entry.target);
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.5 });

  statEls.forEach(el => observer.observe(el));
}

function animateCounter(el) {
  const target = parseInt(el.textContent);
  const duration = 2000;
  const start = Date.now();
  const originalText = el.textContent;

  const animate = () => {
    const elapsed = Date.now() - start;
    const progress = Math.min(elapsed / duration, 1);
    const current = Math.floor(target * progress);
    el.textContent = current;

    if (progress < 1) {
      requestAnimationFrame(animate);
    } else {
      el.textContent = originalText;
    }
  };

  animate();
}
