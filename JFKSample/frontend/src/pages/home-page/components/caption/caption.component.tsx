import * as React from "react"

const style = require("./caption.style.scss");


export const CaptionComponent = () => (
  <div className={style.caption}>
    <p className={style.title}>US Department of State</p>
    <p className={style.subtitle}>Directorate of Defense Trade Controls</p>
  </div>
);