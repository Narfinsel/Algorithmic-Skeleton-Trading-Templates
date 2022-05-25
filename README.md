# Algorithmic-Skeleton-Trading-Templates
Template programming pattern (Skeleton) to be used to build fully customizable trading strategies with configurable open-close trade conditions.

These are fully functional, complete Expert Advisors. You just need to modify/enlarge a few functions - those that specify under which conditions should the buy/sell positions be opened. Here you can add your own trading logic, indicators, position-open strategies.

## 1. Introduction
<strong>Motivation. </strong> <p>I have a new trading strategy idea every day, and I want to implement on the fly as soon as possible. This is why I created these <em>"skeleton" trading bots</em>. These templates just require you to fill in the position-open functions with your own personal strategies. </p>


## 2. Table of Contents
1. [Introduction](#1-introduction)
2. [Table of Contents](#2-table-of-contents)
3. [Project Description](#3-project-description)
   - [Definition & Terminology](#definition--terminology)
4. [How to Install and Run the Project](#4-how-to-install-and-run-the-project)
5. [How to Tweak and Configure the Scanner Script Functionality](#5-how-to-tweak-and-configure-the-scanner-script-functionality)
6. [How to Use the Project](#6-how-to-use-the-project)
7. [Credits](#7-credits)
8. [License](#8-license)


## 3. Project Description
<p>Let's see what are these skeleton trading bots capable of? Here is a short list of steps, capabilities and "hard-coded" actions that the bots can undertake: </p>
<ul>
  <li>Peridically activated function <em>void update_On_New_Bar()</em> - which runs everytime a new candle/bar is created, based on chart timeframe. </li>
  <li>Periodical function is usefull for lagging indicators (Moving Average, EMA, MACD, Ichimoku Cloud, RSI). As you know these indicator are updated based on chart timeframe.</li>
  <li>Use this function to update your indicators, sample new values, use last closed-bar to register new values.</li>
  <li>The only functions you need to worry about are: <strong><em>validateOpenBuy(), validateOpenSell()</em></strong>. This is where you insert and fill in your trading strategy.</li>
  <li>These functions are used inside the main trading function: <strong><em>void algorithm_UniBar_Fixed_TakeProfit()</em></strong>. So you don't need and should not modify this trading method.</li>
  <li> Actions performed by the main trading algorithm <strong><em>void algorithm_UniBar_Fixed_TakeProfit()</em></strong>:
      <ul>
          <li> Enthu. </li>
          <li> Enthu. </li>
          <li> Enthu. </li>
      </ul>
  </li>
</ul>

