import React from "react";
import Link from "next/link"; // or use react-router-dom’s Link for Vite/React Router
import { faStar } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";

/**
 * Renders the Dig|lit top navigation bar with animated stars.
 */
const TopBar: React.FC = () => {
  // Create an array of nine items to map over for stars
  const stars = Array.from({ length: 9 });

  return (
    <header className="bg-black/60 text-white">
      {/* Row with stars and brand */}
      <div className="flex items-center justify-between px-4 py-2">
        {/* Animated stars */}
        <div className="flex space-x-1">
          {stars.map((_, idx) => (
            <FontAwesomeIcon
              key={idx}
              icon={faStar}
              className={`text-yellow-400 animate-twinkle-${idx % 3}`}
            />
          ))}
        </div>

        {/* Brand split: Dig | lit */}
        <div className="flex items-center font-serif text-2xl">
          <span>Dig</span>
          <Link href="#about" className="px-2 hover:underline">
            |
          </Link>
          <span>lit</span>
        </div>

        {/* Primary navigation links (hidden on small screens) */}
        <nav className="hidden md:flex space-x-5 uppercase text-sm tracking-wider">
          <Link href="#solution" className="hover:text-purple-300">
            Solution
          </Link>
          <Link href="#service" className="hover:text-purple-300">
            Service
          </Link>
          <Link href="#shop" className="hover:text-purple-300">
            Shop
          </Link>
          <Link href="#partner" className="hover:text-purple-300">
            Partner
          </Link>
          <Link href="#home" className="hover:text-purple-300">
            Home
          </Link>
        </nav>
      </div>

      {/* CTA section */}
      <div className="flex justify-center py-3">
        <Link
          href="#contact"
          className="rounded-full bg-gradient-to-r from-purple-600 to-indigo-700 px-6 py-2 text-sm font-medium shadow-lg transition hover:shadow-xl"
        >
          Let’s&nbsp;Connect
        </Link>
      </div>
    </header>
  );
};

export default TopBar;
