import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import axios from 'axios';
import useAuthStore from '../store/authStore';
import logo from "../images/logoKengelapp.png";
import logoGoogle from "../images/logoGoogle.png";

const LoginForm = () => {
  const navigate = useNavigate();
  const { login } = useAuthStore();

  const [email, setEmail] = useState('');
  const [motdepasse, setMotdepasse] = useState('');
  const [seSouvenir, setSeSouvenir] = useState(false);
  const [error, setError] = useState('');

  const isValidEmail = (email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    if (!isValidEmail(email)) {
      setError("Adresse email invalide. Ex: utilisateur@exemple.com");
      return;
    }

    try {
      const res = await axios.post("http://localhost:5000/kengelapp/auth/login", {
        EmailUser: email,
        MotdepasseUser: motdepasse
      });

      const token = res.data.token;

      const userRes = await axios.get("http://localhost:5000/kengelapp/auth/me", {
        headers: { Authorization: `Bearer ${token}` }
      });

      login(token, userRes.data, seSouvenir);
      navigate("/dashboard");

    } catch (err) {
      setError("Email ou mot de passe incorrect.");
    }
  };

  return (
    <div className='flex justify-between items-center w-full overflow-hidden'>
      {/* block de gauche */}
      <div className="h-screen flex flex-col items-start justify-start gap-6 py-20">
        <div className="relative left-[-40px] w-48 h-20 bg-blue-200 rounded-xl rotate-[-25deg]"></div>
        <div className="relative left-[-40px] w-48 h-20 bg-orange-200 rounded-xl rotate-[-25deg]"></div>
      </div>

      {/* formulaire */}
      <div className="flex flex-col justify-start items-between gap-4">
        <div className="flex flex-col items-center py-5 gap-5">
          <img src={logo} alt="Logo" className="w-1/2" />
          <p className="font-semibold text-lg">Connectez-vous à votre compte</p>
        </div>

        <form onSubmit={handleSubmit} className="w-full flex flex-col justify-start items-start gap-6 p-10 border shadow-md rounded-lg">
          {error && <p className="text-red-500">{error}</p>}

          <div className="w-full flex flex-col items-start gap-2">
            <span className="font-medium">Adresse email</span>
            <input
              type="email"
              value={email}
              onChange={e => setEmail(e.target.value)}
              className="w-full px-2 py-3 rounded-md border focus:border-blue-400 outline-none"
              required
            />
          </div>

          <div className="w-full flex flex-col items-start gap-2">
            <span className="font-medium">Mot de passe</span>
            <input
              type="password"
              value={motdepasse}
              onChange={e => setMotdepasse(e.target.value)}
              className="w-full px-2 py-3 rounded-md border focus:border-blue-400 outline-none"
              required
            />
          </div>

          <div className="flex items-center justify-between gap-20 w-full">
            <label className="flex items-center gap-2.5 cursor-pointer">
              <input
                type="checkbox"
                checked={seSouvenir}
                onChange={() => setSeSouvenir(!seSouvenir)}
              />
              <span>Se souvenir de moi</span>
            </label>
            <p><Link to="">Mot de passe oublié ?</Link></p>
          </div>

          <button type="submit" className="w-full px-5 py-2.5 bg-orange-500 hover:bg-orange-600 text-white text-center rounded-lg">
            Se connecter
          </button>

          <p className="w-full text-center text-gray-500">ou continuer avec</p>

          <button type="button" className="w-full flex items-center justify-center gap-4 border border-black px-5 py-2.5 font-semibold text-md text-center rounded-lg">
            <img src={logoGoogle} alt="Google" className="w-5" />
            <span>Mon compte Google</span>
          </button>
        </form>

        <p className="w-full text-center">
          <span>Je n'ai pas de compte </span>
          <Link to="">M'inscrire</Link>
        </p>
      </div>

      {/* block de droite */}
      <div className="h-screen py-20 flex flex-col items-start justify-end gap-6">
        <div className="relative right-[-40px] w-48 h-20 bg-blue-200 rounded-xl rotate-[25deg]"></div>
        <div className="relative right-[-40px] w-48 h-20 bg-orange-200 rounded-xl rotate-[25deg]"></div>
      </div>
    </div>
  );
};

export default LoginForm;
