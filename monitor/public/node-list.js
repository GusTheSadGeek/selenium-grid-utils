

// Use abstract equality == for "is number" test
function isEven(n) {
    return n == parseFloat(n)? !(n%2) : void 0;
}

// Use strict equality === for "is number" test
function isEvenStrict(n) {
    return n === parseFloat(n)? !(n%2) : void 0;
}

var node_list = {
    nodes: [],

//    browser_total: 0,
//    browser_per_col: 0,
//    browser_cols: 3,
//    icon_size: 0,
 //   browser_para: 'para2',

    add: function(data) {
        this.nodes.push(data);
    },

    clear: function() {
        this.nodes = [];
    },

    remove: function(index) {
        this.nodes.splice(index, 1);
        this.render();
    },

    render: function() {
        var self = this;
//        var container = $('#node-list').first().sortable('destroy');
//        container.find(".node").remove();

        var lcontainer = $('#leftColumn');
        var rcontainer = $('#rightColumn');
        lcontainer.find(".node").remove();
        rcontainer.find(".node").remove();

        if(this.nodes.length) {
//            lcontainer.show();
            var i = 0;
            for (var key in this.nodes) {
                if (isEven(i)) {
                    lcontainer.append(this.render_node(this.nodes[key], i));
                } else {
                    rcontainer.append(this.render_node(this.nodes[key], i));
                }
                i = i + 1;
            }
        }
        else {
            container.hide();
        }
    },



    render_node_left: function(node) {
        var div = document.createElement('div');
        var nok = 0;
        var s = String(node['status']);
        if (s && (typeof s !== 'undefined')) {
            if (s.indexOf("NOK") > -1) {
                div.className = 'nok';
                nok = 1
            }
            else {
                div.className = 'ok';
            }
        }

        var label1 = document.createElement("p");
        label1.className = "para";
        label1.innerText = "Name : " + node['vm_name'] + ' - Grid Ref: ' +node['grid_ref'];
        div.appendChild(label1);

        var label2 = document.createElement("p");
        label2.className = "para";
        label2.innerText = "Host : " + node['host_name'];
        div.appendChild(label2);

        var label3 = document.createElement("p");
        label3.className = "para";
        label3.innerText = "Status : " + node['status'];
        div.appendChild(label3);

        var label4 = document.createElement("p");
        label4.className = "para";
        label4.innerText = "Max Sessions : " + node['max_sessions'];
        div.appendChild(label4);

        if (node['os_version']) {
            var label5 = document.createElement("p");
            label5.className = "para";
            label5.innerText = "OS ver: " + node['os_version'];
            div.appendChild(label5);
        }

        if (node['max_ie'] > 0) {
            if (node['ie_version']) {
                var label6 = document.createElement("p");
                label6.className = "para";
                label6.innerText = "IE: " + node['max_ie'] + '   Ver: ' + node['ie_version'];
                div.appendChild(label6);
            }
        }

        if (node['max_ff'] > 0){
            if (node['ff_version']) {
                var label7 = document.createElement("p");
                label7.className = "para";
                label7.innerText = "FF: " + node['max_ff'] + '   Ver: ' + node['ff_version'];
                div.appendChild(label7);
            }
        }

        if (node['max_ch'] > 0) {
            if (node['ch_version']) {
                var label8 = document.createElement("p");
                label8.className = "para";
                label8.innerText = "CH: " + node['max_ch'] + '   Ver: ' + node['ch_version'];
                div.appendChild(label8);
            }
        }
        if (node['max_saf'] > 0) {
            if (node['saf_version']) {
                var label9 = document.createElement("p");
                label9.className = "para";
                label9.innerText = "Safari ver: " + node['saf_version'];
                label9.innerText = "SAF: " + node['max_saf'] + ' Ver: ' + node['saf_version'];
                div.appendChild(label9);
            }
        }


        if (nok) {
            var label10 = document.createElement("p");
            label10.className = "para";
            label10.innerText = "Last seen OK : " + node['lastseen'];
            div.appendChild(label10);
        }

        if (node['remote_cmd']) {
            var plabel1 = document.createElement("p");
            plabel1.className = "para";
            var label11 = document.createElement("a");
            label11.className = "para";
            label11.href = "rdesktop://" + node['remote_cmd'];
            label11.innerText = "rdesktop";
            plabel1.appendChild(label11);
            div.appendChild(plabel1);
        }

        var plabel2 = document.createElement("p");
        plabel2.className = "para";
        var label12 = document.createElement("a");
        label12.className = "para";
        label12.href = 'http://'+node['host_name']+":"+node['wd_port'];
        label12.innerText = "node options";
        plabel2.appendChild(label12);
        div.appendChild(plabel2);


        var el = document.createElement('td');
        el.className = 'info';
        el.appendChild(div);

        return el;
    },


    render_job: function(job) {
        var imagesrc = "assets/internet_explorer.png";
        if (job['br'].indexOf('IE') > -1){
            imagesrc = "assets/internet_explorer.png";
        }
        if (job['br'].indexOf('FF') > -1){
            imagesrc = "assets/firefox.png";
        }
        if (job['br'].indexOf('CH') > -1){
            imagesrc = "assets/chrome.png";
        }
        if (job['br'].indexOf('SAF') > -1){
            imagesrc = "assets/safari.png";
        }


        var p = document.createElement("p");
        p.className='para2';
        var img = document.createElement("img");
//        if (this.icon_size==0) {
            img.className = "icon_small";
//        }else{
 //           img.className = "icon_large"
   //     }

        img.src = imagesrc;
        p.appendChild(img);
        var a = document.createElement("a");
        a.className='para2';
        a.innerText = job['info'];
        p.appendChild(a);
        return p;
    },

    render_node_jobs: function(jobs, col) {
        var el = document.createElement('td');
        el.className = "jobs";

        var label = document.createElement("div");
        label.className = "icons";

        var i = 0;
        for (var key in jobs) {
            if (jobs.hasOwnProperty(key)) {
                if ((col == 0) && (i < 6)) {
                    label.appendChild(this.render_job(jobs[key]));
                }
                if ((col == 1) && (i > 5)) {
                    label.appendChild(this.render_job(jobs[key]));
                }
                i++;
            }
        }
        el.appendChild(label);
        return el;
    },


    render_node: function(node) {
//        var self = this;
        var jobCols = 1;
        var nodeCount = 0;
        for (var key in node['jobs']) {
            if (node['jobs'].hasOwnProperty(key)) nodeCount++;
        }
        if (nodeCount > 6)
        {
            jobCols = 2;
        }

        var tr = document.createElement('tr');

        var leftColwidth = document.createElement('col');
        leftColwidth.width = "40%";

        var jobColWidth = document.createElement('col');
        if (jobCols > 1) {
            jobColWidth.width = "30%";
        }else{
            jobColWidth.width = "60%";
        }

        var table = document.createElement('table');
        table.className="tt";
        table.appendChild(tr);
        table.appendChild(leftColwidth);
        table.appendChild(jobColWidth);
        if (jobCols > 1) {
            tr.appendChild(jobColWidth);
        }

        table.appendChild(this.render_node_left(node));
        table.appendChild(this.render_node_jobs(node['jobs'],0));
        if (jobCols > 1) {
            table.appendChild(this.render_node_jobs(node['jobs'],1));
        }

        var el = document.createElement('div');
        el.className="node";
        el.appendChild(table);

        return el;
    }
};