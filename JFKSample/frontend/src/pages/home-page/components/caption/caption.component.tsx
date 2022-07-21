import * as React from "react"

const style = require("./caption.style.scss");


export const CaptionComponent = () => (
  <div className={style.caption}>
    <p className={style.title}>Plum Island Animal Disease Center</p>
    <p className={style.subtitle}>The front line of the nation’s defense against diseases.</p>
  </div>
);