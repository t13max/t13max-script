// ==UserScript==
// @name         自动删除有道翻译的AI翻译
// @namespace    https://gitee.com/an-tingbi
// @version      2024-07-11
// @description  自动删除有道翻译的AI翻译, 总是弹窗挡着我烦死了!
// @author       T13MAX
// @match        https://fanyi.youdao.com/
// @icon         https://www.google.com/s2/favicons?sz=64&domain=fanyi.youdao.com
// @grant        none
// ==/UserScript==

(function() {

    'use strict';
    alert('Test script loaded');
    // 选择要移除的元素
    const elementsToRemove = [
        'div.tab-item.color_text_3.tab-item-ai.gradient-item'
    ];

    // 移除元素
    function removeElements() {
        elementsToRemove.forEach(selector => {
            const elements = document.querySelectorAll(selector);
            elements.forEach(function(div) {
                div.parentNode.removeChild(div);
            });
        });
    }

    //点击翻译
    function clickTranslate() {
        let targetDiv = document.querySelector('.tab-item.color_text_3');
        targetDiv.click();
    }

    // 在页面加载完成后执行
    window.addEventListener('load', () => {
        //点一下翻译
        setTimeout(clickTranslate,500);
        //延迟执行
        setTimeout(removeElements,1000);
    });


})();